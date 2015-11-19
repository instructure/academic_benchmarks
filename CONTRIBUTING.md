# Academic Benchmarks Ruby Library

_Brought to you by your friends at [Instructure](https://www.instructure.com/)_ :heart:

## Contributing

There are two wonderful ways you can contribute: filing issues and
submitting pull requests.

## Filing Issues

When filing issues, we need to see details about what the problem is, what steps need to
be taken to reproduce the problem, and what you expect the behavior to be.
It might be helpful to copy the following and use it as a template when writing up an issue:

```
Summary:
Steps to reproduce:
Expected behavior:
Additional notes:
```

We’ll try to get back to you in a timely manner and let you know if we need more details or not
and any status we can provide on expectation for a fix.

## Submitting Pull Requests

In order for us to continue to dual-license our Canvas product to best serve all
of our customers, we need you to sign [our contributor agreement](https://github.com/instructure/canvas-lms/wiki/ica.pdf)
before we can accept a pull request from you. Please read our [FAQ](https://github.com/instructure/canvas-lms/wiki/FAQ)
for more information.

If you choose to contribute, following these guidelines will make things easier
for you and for us:

*  Match our style.  It doesn't have to be perfect but inconsistent styles in a codebase can make reading the code difficult
*  Write a test.  Not everything is testable, but most things are.  If you can, write a test.  If you don't know how, send a PS and we'll try to work with you.
*  Update the documentation.  If your feature should be in the README, then add it!  Also, if it makes sense, please add a manual verification step to TESTPLAN.md.
* Your pull request should generally consist of a single commit.  This helps keep the git history clean
by keeping each commit focused on a single purpose.  If you have multiple commits that keep that focus
then that is acceptable, however "train of thought" commits should not be in the history.
* Your commit message should follow this general format:

   ```
    Summary of the commit (Subject)

    Further explanation of the commit, generally focusing on why you chose
    the approach you did in making this change.

    closes gh-123 (if this closes a GitHub Issue)

    Test Plan:
      - Use this space to enumerate steps that need to be taken to test this commit
      - This is important for our in house QA personnel to be able to test it.
   ```

   This format is the format that Instructure engineers follow.  You could look at previous commits in the
   repository for real world examples.
* The process your pull request goes through is as follows:
    * An Instructure engineer will pull the request down and run it through our automated test suite.
  They will report back with results of the testing.  You can help this process along by running the tests prior to submission:  `bundle exec rspec spec/`
    * Once the test passes against our test suites, one or two engineers will look over the code and provide
      a code review.
    * Once the code review has been successful our QA engineers will run through the test plan that has
      been provided and make sure that everything is good to go.
    * Once all these things have occurred then an engineer will merge your commit into the repository.
    * Congratulations! You are now a contributor!
