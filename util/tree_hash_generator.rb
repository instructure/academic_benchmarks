require 'securerandom'

module AcademicBenchmarks
  module Utils
    class TreeHashGenerator
      def self.new_tree(depth: 2, num_children: 3)
        tree = [self.new_standard(number: next_number)]
        parent_guid = tree.first["data"]["guid"]
        tree.concat(self.create_children(
          num_children: num_children,
          parent_guid: parent_guid,
          depth: depth
        ))
        tree
      end

      def self.next_number
        @next_number ||= 0
        @next_number += 1
      end

      def self.new_standard(parent: nil, number: nil, guid: nil, descr: nil)
        number ||= Random.new.rand(4000000000)
        number = "1.#{number}"
        descr ||= "This description is for standard number #{number}"
        guid ||= SecureRandom.uuid

        retval = self.BASE_STANDARD.dup
        retval["data"]["guid"] = guid
        retval["data"]["self"] = "#{retval['data']['self']}/#{guid}"
        retval["data"]["number"] = number
        retval["data"]["descr"] = descr
        retval["data"]["parent"] = parent if parent
        retval
      end

      def self.BASE_STANDARD
        {
          "data" => {
            "number" => "1.",
            "status" => "Active",
            "self" => "http://api.academicbenchmarks.com/rest/v3/standards",
            "grade" => {
              "high" => "10",
              "low" => "1",
              "seq" => "510"
            },
            "document" => {
              "guid" => "993690BE-C0DA-11DA-BD64-B7CEA439013B",
              "title" => "Academic Standards"
            },
            "subject_doc" => {
              "guid" => "41ba4f1d-2568-4a2b-94d5-85c5d3dc22fc",
              "descr" => "English/Language Arts (2014)"
            },
            "guid" => "81ce1544-ff83-42d4-bb3b-f0b8b1078e21",
            "placeholder" => "N",
            "course" => {
              "guid" => "14e063e8-4bdb-4561-a4d1-055e97d4284c",
              "descr" => "Grade 1"
            },
            "subject" => {
              "broad" => "LANG",
              "code" => "LANG"
            },
            "version" => "4.4.2",
            "has_relations" => {
              "origin" => 1,
              "related_derivative" => 1
            },
            "date_modified" => "2014-06-11 11:56:06",
            "deepest" => "N",
            "descr" => "Reading: Foundations",
            "level" => 1,
            "label" => "Strand",
            "adopt_year" => "2014",
            "authority" => {
              "guid" => "A8334A58-901A-11DF-A622-0C319DFF4B22",
              "descr" => "Indiana",
              "code" => "IN"
            }
          }
        }
      end

      private

      def self.create_children(depth:, parent_guid:, num_children:, current_depth: 1)
        retval = []
        num_children.times do
          retval.push(self.new_standard(
            number: next_number,
            parent: parent_guid
          ))
          if current_depth < (depth - 1)
            retval.concat(create_children(
              parent_guid: retval.last["data"]["guid"],
              num_children: num_children,
              depth: depth,
              current_depth: current_depth + 1
            ))
          end
        end
        retval
      end
    end
  end
end
