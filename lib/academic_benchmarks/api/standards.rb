require 'active_support/hash_with_indifferent_access'

require 'academic_benchmarks/api/auth'
require 'academic_benchmarks/api/constants'

module AcademicBenchmarks
  module Api
    class Standards
      DEFAULT_PER_PAGE = 100

      STANDARDS_FIELDS = %w[
        guid
        education_levels.grades.code
        label
        level
        section.guid
        section.descr
        number.prefix_enhanced
        status
        disciplines.subjects.code
        document.guid
        document.descr
        document.adopt_year
        document.publication.descr
        document.publication.guid
        document.publication.authorities
        statement.descr
        utilizations.type
        parent
      ]

      def initialize(handle)
        @handle = handle
      end

      # TODO: in the future, support OData filtering for flexible querying
      def search(authority_guid: nil, publication_guid: nil)
        raw_search(authority: authority_guid, publication: publication_guid).map do |standard|
          AcademicBenchmarks::Standards::Standard.new(standard)
        end
      end

      def authorities
        raw_facet("document.publication.authorities").map do |a|
          AcademicBenchmarks::Standards::Authority.from_hash(a["data"])
        end
      end

      def publications(authority_guid: nil)
        raw_facet("document.publication", authority: authority_guid).map do |a|
          AcademicBenchmarks::Standards::Publication.from_hash(a["data"])
        end
      end

      def authority_publications(authority_or_auth_code_guid_or_desc)
        authority = auth_from_code_guid_or_desc(authority_or_auth_code_guid_or_desc)
        publications(authority_guid: authority.guid)
      end

      def authority_tree(authority_or_auth_code_guid_or_desc, include_obsolete_standards: true, exclude_examples: false)
        authority = auth_from_code_guid_or_desc(authority_or_auth_code_guid_or_desc)
        auth_children = raw_search(authority: authority.guid, include_obsoletes: include_obsolete_standards, exclude_examples: exclude_examples)
        AcademicBenchmarks::Standards::StandardsForest.new(
          auth_children
        ).consolidate_under_root(authority)
      end

      def publication_tree(publication_or_pub_code_guid_or_desc, include_obsolete_standards: true, exclude_examples: false)
        publication = pub_from_guid(publication_or_pub_code_guid_or_desc)
        pub_children = raw_search(publication: publication.guid, include_obsoletes: include_obsolete_standards, exclude_examples: exclude_examples)
        AcademicBenchmarks::Standards::StandardsForest.new(
          pub_children
        ).consolidate_under_root(publication)
      end

      private

      def auth_from_code_guid_or_desc(authority_or_auth_code_guid_or_desc)
        if authority_or_auth_code_guid_or_desc.is_a?(AcademicBenchmarks::Standards::Authority)
          authority_or_auth_code_guid_or_desc
        else
          find_type(type: "authority", data: authority_or_auth_code_guid_or_desc)
        end
      end

      def pub_from_guid(publication_or_pub_code_guid_or_desc)
        if publication_or_pub_code_guid_or_desc.is_a?(AcademicBenchmarks::Standards::Publication)
          publication_or_pub_code_guid_or_desc
        else
          find_type(type: "publication", data: publication_or_pub_code_guid_or_desc)
        end
      end

      def find_type(type:, data:)
        matches = send("match_#{type}", data)
        if matches.empty?
          raise StandardError.new(
            "No #{type} code, guid, or description matched '#{data}'"
          )
        elsif matches.count > 1
          raise StandardError.new(
            "#{type.upcase} code, guid, or description matched more than one #{type}.  " \
            "matched '#{matches.map(&:to_json).join('; ')}'"
          )
        end
        matches.first
      end

      def match_authority(data)
        authorities.select do |auth|
          auth.acronym  == data ||
          auth.guid  == data ||
          auth.descr == data
        end
      end

      def match_publication(data)
        publications.select do |pub|
          pub.acronym == data ||
          pub.guid == data ||
          pub.descr == data
        end
      end

      def raw_facet(facet, query_params = {})
        request_facet({facet: facet}.merge(query_params).merge(auth_query_params))
      end

      def raw_search(opts = {})
        request_search_pages_and_concat_resources(opts.merge(auth_query_params))
      end

      def auth_query_params
        AcademicBenchmarks::Api::Auth.auth_query_params(
          partner_id: @handle.partner_id,
          partner_key: @handle.partner_key,
          expires: AcademicBenchmarks::Api::Auth.expire_time_in_2_hours,
          user_id: @handle.user_id
        )
      end

      def odata_filters(query_params)
        if query_params.key? :authority
          value = query_params.delete :authority
          query_params['filter[standards]'] = "document.publication.authorities.guid eq '#{value}'" if value
        end
        if query_params.key? :publication
          value = query_params.delete :publication
          query_params['filter[standards]'] = "document.publication.guid eq '#{value}'" if value
        end

        if query_params.key? :include_obsoletes
          unless query_params.delete :include_obsoletes
            if query_params.key? 'filter[standards]'
              query_params['filter[standards]'] += " and status eq 'active'"
            else
              query_params['filter[standards]'] = "status eq 'active'"
            end
          end
        end

        if query_params.delete :exclude_examples
          if query_params.key? 'filter[standards]'
            query_params['filter[standards]'] += " and utilizations.type not eq 'example'"
          else
            query_params['filter[standards]'] = "utilizations.type not eq 'example'"
          end
        end
      end

      def request_facet(query_params)
        odata_filters query_params
        page = request_page(
          query_params: query_params,
          limit: 0, # return no standards since facets are separate
          offset: 0
        ).parsed_response

        page.dig("meta", "facets", 0, "details")
      end

      def request_search_pages_and_concat_resources(query_params)
        query_params['fields[standards]'] = STANDARDS_FIELDS.join(',')
        odata_filters query_params
        query_params.reverse_merge!({limit: DEFAULT_PER_PAGE})

        if !query_params[:limit] || query_params[:limit] <= 0
          raise ArgumentError.new(
            "limit must be specified as a positive integer"
          )
        end

        first_page = request_page(
          query_params: query_params,
          limit: query_params[:limit],
          offset: 0
        ).parsed_response

        resources = first_page["data"]
        count = first_page["meta"]["count"]
        offset = query_params[:limit]
        while offset < count
          page = request_page(
            query_params: query_params,
            limit: query_params[:limit],
            offset: offset
          )
          offset += query_params[:limit]
          resources.push(page.parsed_response["data"])
        end

        resources.flatten
      end

      def request_page(query_params:, limit:, offset:)
        query_params.merge!({
          limit: limit,
          offset: offset,
        })
        1.times do
          resp = @handle.class.get(
            '/standards',
            query: query_params.merge({
              limit: limit,
              offset: offset,
            })
          )
          if resp.code == 429
            sleep retry_after(resp)
            redo
          end
          if resp.code != 200
            raise RuntimeError.new(
              "Received response '#{resp.code}: #{resp.message}' requesting standards from Academic Benchmarks:"
            )
          end
          return resp
        end
      end

      def retry_after(response)
        ENV['ACADEMIC_BENCHMARKS_TOO_MANY_REQUESTS_RETRY']&.to_f || 5
      end
    end
  end
end
