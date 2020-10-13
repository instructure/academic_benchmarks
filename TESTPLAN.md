# Academic Benchmarks Ruby Library

_Brought to you by your friends at
[Instructure](https://www.instructure.com/)_ :heart:

## Test Plan (Manual Testing)

There are many automated tests in the form of specs
which can be run as follows:

    bundle exec rspec spec/

However, you may wish to verify functionality manually.
If so, here are some steps to verify this library.
You will need credentials (see README.md):

### Install the current version of the gem and start up an interactive ruby console with the gem loaded:

#### Using docker:

1. Build the docker container from the root directory of the project:

    ```
    docker build -t academic_benchmarks .
    ```

1. Run it!

    ```
    docker run -it academic_benchmarks
    ```

#### Into your native ruby installation:

1. First make sure no other versions of the gem are installed:

    ```
    gem uninstall academic_benchmarks
    ```

1. From the root directory of the project, build a new version of gem:

    ```
    gem build academic_benchmarks.gemspec
    ```

1. Now install the newly built gem, substituting the
current version for <gem-ver> below:

    ```
    gem install academic_benchmarks-<gem-ver>.gem
    ```

1. Start up an interactive console and require the
`academic_benchmarks` gem:

    ```
    $ irb
    irb(main):001:0> require 'academic_benchmarks'
    ```

### Check authentication works properly and authorities list properly:

1. Pass-in credentials directly:

    ```
    ab_handle = AcademicBenchmarks::Api::Handle.new(partner_id: 'my-id', partner_key: 'my-key')
    ```

1. Now list authorities and make sure you get a list of
authorities back.  What comes back will depend on your
subscription.  For a sandbox it might look like this:

    ```
    ab_handle.standards.authorities.map(&:to_h)
    {:acronym=>"FDOE", :guid=>"9127FF50-F1B9-11E5-862E-0938DC287387", :description=>"Florida DOE"}
    {:acronym=>nil, :guid=>"9128B2EC-F1B9-11E5-862E-0938DC287387", :description=>"Indiana DOE"}
    {:acronym=>"MDE", :guid=>"91290080-F1B9-11E5-862E-0938DC287387", :description=>"Michigan DOE"}
    ```

1. Now put your credentials into environment variables.
If you use bash:

    ```
    export ACADEMIC_BENCHMARKS_PARTNER_ID='my-id'
    export ACADEMIC_BENCHMARKS_PARTNER_KEY='my-key'
    ```

1. Now instantiate and list authorities again, making
sure to get the same thing back:

    ```
    ab_handle = AcademicBenchmarks::Api::Handle.init_from_env
    ab_handle.standards.authorities
    ```

1. Now obtain a list of publications:

    ```
    ab_handle.standards.publications
    ```

### Search for standards

1. Retrieve all standards from a certain authority
(Indiana given in the example)

    ```
    ab_handle.standards.search(authority_guid: "9128B2EC-F1B9-11E5-862E-0938DC287387")
    ```

    You should get back an array of standards
    belonging to the Indiana authority

1. Retrieve all standards from a certain publication
(Common Core State Standards given in the example)

    ```
    ab_handle.standards.search(authority_guid: "964E0FEE-AD71-11DE-9BF2-C9169DFF4B22")
    ```

    You should get back an array of standards
    belonging to the CCSS publication

### Retrieve a tree of standards belonging to an Authority

1. Request the tree.  You can pass either an authority
code, guid, or description to the `authority_tree`
method and it will find the corresponding Authority
object.  Note that this may take some time depending
on how many standards are in the tree.

    ```
    auth_tree = ab_handle.standards.authority_tree(authority)
    ```

    Observe that auth_tree is a data structure that has
    an Authority object at the top, with children that have
    children that have children, etc.  Here is a suggestion
    on how to do it.  All of these statements should
    evaluate to true:

    ```
    auth_tree.class == AcademicBenchmarks::Standards::StandardsTree
    auth_tree.root.class == AcademicBenchmarks::Standards::Authority
    auth_tree.root.code == <the code of the authority you passed in, if it has one>
    auth_tree.children.count > 0
    auth_tree.children.first.class == AcademicBenchmarks::Standards::Publication
    auth_tree.children.first.children.count > 0
    auth_tree.children.first.children.first.class == AcademicBenchmarks::Standards::Document
    auth_tree.children.first.children.first.children.count > 0
    auth_tree.children.first.children.first.children.first.class == AcademicBenchmarks::Standards::Section
    auth_tree.children.first.children.first.children.first.children.count > 0
    auth_tree.children.first.children.first.children.first.children.first.class == AcademicBenchmarks::Standards::Standard
    ```

### Retrieve a tree of standards belonging to a Publication

1. Request the tree.  You can pass either a Publication
object or guid to the `publication_tree`
method and it will find the corresponding Publication
object.  Note that this may take some time depending
on how many standards are in the tree.


    ```
    pub_tree = ab_handle.standards.publication_tree(publication)
    ```

    Observe that pub_tree is a data structure that has a Publication
    object at the top, with children that have children that have
    children, etc.  Here is a suggestion on how to do it.
    All of these statements should evaluate to true:

    ```
    pub_tree.class == AcademicBenchmarks::Standards::StandardsTree
    pub_tree.root.class == AcademicBenchmarks::Standards::Publication
    pub_tree.root.guid == <the guid of the publication that you passed in>
    pub_tree.children.count > 0
    pub_tree.children.first.class == AcademicBenchmarks::Standards::Document
    pub_tree.children.first.children.count > 0

    pub_tree.children.first.children.first.class == AcademicBenchmarks::Standards::Section
    pub_tree.children.first.children.first.children.count > 0
    pub_tree.children.first.children.first.children.first.class == AcademicBenchmarks::Standards::Standard
    ```
