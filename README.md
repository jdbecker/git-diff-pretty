# git-diff-pretty
If you're interested in trying this, copy this entire directory to your computer, or it won't quite work like it should.

Before you run this, you'll want to run the script `InstallRegressionDiff.ps1` and then restart powershell. This installs RegressionDiff as a module
and enables you to run the following commands without having to point directly at the files.

When you're ready, go to the repo you want to diff and run `RegressionDiff`

    D:\Sourcecode\ [develop ≡]> RegressionDiff release HEAD

This example will run the script, walk you through some first time setup, and then execute the diff between the larkspur branch and current HEAD.
Additionally, the "after" branch now defaults to "HEAD", so you can further simplify the command as just:

    D:\Sourcecode\ [develop ≡]> RegressionDiff release

Again, this does the same thing as the previous example. The second parameter is optional, for if you want to diff between two non-head tags/branches.
For more specific examples for how to forman your $before and $after parameters, any valid gitrevision syntax should be accepted.
See here: https://git-scm.com/docs/gitrevisions

Finally, if at any time you need to Edit your team, type this command and follow the instructions:

    D:\Sourcecode\ [develop ≡]> EditTeam

Remember, this was hacked out in a day, so it's probably still buggy. Be gentle with it!
