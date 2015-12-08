# Academic Benchmarks Ruby Library

_Brought to you by your friends at [Instructure](https://www.instructure.com/)_ :heart:

## Test Plan (Manual Testing)

There are many automated tests in the form of specs which can be run as follows:

    bundle exec rspec spec/

However, you may wish to verify functionality manually.  If so, here are some steps to verify this library.  You will need credentials (see README.md):

### Install the current version of the gem and start up an interactive ruby console with the gem loaded:

1. First make sure no other versions of the gem are installed:

    ```
    gem uninstall academic_benchmarks
    ```

1. From the root directory of the project, build a new version of gem:

    ```
    gem build academic_benchmarks.gemspec
    ```

1. Now install the newly built gem, substituting the current version for <gem-ver> below:

    ```
    gem install academic_benchmarks-<gem-ver>.gem
    ```

1. Start up an interactive console and require the `academic_benchmarks` gem:

    ```
    $ irb
    irb(main):001:0> require 'academic_benchmarks'
    ```

### Check authentication works properly and authorities list properly:

1. Pass-in credentials directly:

    ```
    ab_handle = AcademicBenchmarks::Api::Handle.new(partner_id: 'my-id', partner_key: 'my-key')
    ```

1. Now list authorities and make sure you get a list of authorities back.  What comes back will depend on your subscription.  For a sandbox it might look like this:

    ```
    ab_handle.standards.authorities
    {:code=>"IN", :guid=>"A8334A58-901A-11DF-A622-0C319DFF4B22", :description=>"Indiana"}
    {:code=>"CC", :guid=>"A83297F2-901A-11DF-A622-0C319DFF4B22", :description=>"NGA Center/CCSSO"}
    {:code=>"OH", :guid=>"A834F40C-901A-11DF-A622-0C319DFF4B22", :description=>"Ohio"}
    ```

1. Now put your credentials into environment variables.  If you use bash:

    ```
    export ACADEMIC_BENCHMARKS_PARTNER_ID='my-id'
    export ACADEMIC_BENCHMARKS_PARTNER_KEY='my-key'
    ```

1. Now instantiate and list authorities again, making sure to get the same thing back:

    ```
    ab_handle = AcademicBenchmarks::Api::Handle.init_from_env
    ab_handle.standards.authorities
    ```

### Search for standards

1. Search for some some text within standards:

    ```
    ab_handle.standards.search(query: "rectangle")
    ```

    You should get back an array of standards

1. Retrieve all standards from a certain authority (Indiana given in the example)

    ```
    ab_handle.standards.search(authority: "IN")
    ```

    You should get back an array of standards belonging to the Indiana (IN) authority

### Retrieve a specified guid

1. Find a guid from a standard in one of the previous steps and insert it below:

    ```
    ab_handle.standards.guid("<some-guid>">)
    ```

    Observe that the appropriate standard is returned
