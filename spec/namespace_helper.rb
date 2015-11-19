# This helper shortens up the namespaced classes to 
# reduce the amount of typing required

require_relative '../util/tree_hash_generator'

# Api
Auth = AcademicBenchmarks::Api::Auth
Constants = AcademicBenchmarks::Api::Constants
Handle = AcademicBenchmarks::Api::Handle
Standard = AcademicBenchmarks::Standards::Standard
Standards = AcademicBenchmarks::Api::Standards

# Standards
Authority = AcademicBenchmarks::Standards::Authority
Course = AcademicBenchmarks::Standards::Course
Document = AcademicBenchmarks::Standards::Document
Grade = AcademicBenchmarks::Standards::Grade
HasRelations = AcademicBenchmarks::Standards::HasRelations
Parent = AcademicBenchmarks::Standards::Parent
StandardsForest = AcademicBenchmarks::Standards::StandardsForest
StandardsTree = AcademicBenchmarks::Standards::StandardsTree
Subject = AcademicBenchmarks::Standards::Subject
SubjectDoc = AcademicBenchmarks::Standards::SubjectDoc

# Utils
TreeHashGenerator = AcademicBenchmarks::Utils::TreeHashGenerator
