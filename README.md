buildkite-phabricator-dev
=========================

A Dockerized environment for developing and testing our [buildkite-patches branch of Phabricator](https://github.com/buildkite/phabricator/tree/buildkite-patches).

## Getting Started

```bash
# Clone our patches branch and other phabricator libs
git clone -b buildkite-patches https://github.com/buildkite/phabricator.git
git clone https://github.com/phacility/libphutil.git
git clone https://github.com/phacility/arcanist.git

# Start it up (will bootstrap the DB)
docker-compose up

# Setup up Pow, or somesuch localhost proxy
echo '8081' > '~/.pow/phabricator'

# Give it a go (see Quick Setup for next instructions)
open http://phabricator.dev/
```

## Quick Setup

* Name your admin user 'test'
* Set a VCS password: http://phabricator.dev/settings/user/test/page/vcspassword/ This will be used to test `git clone` commands on the command line
* Create a new Git repository called 'Test': http://phabricator.dev/diffusion/edit/form/default/?vcs=git
* Activate the repository: http://phabricator.dev/diffusion/1/manage/basics/

## First git commit

```bash
$ git clone http://phabricator.dev/diffusion/1/test.git
Cloning into 'test'...
warning: You appear to have cloned an empty repository.
$ cd test
$ touch Readme.md
$ git commit -am "Initial commit"
[master (root-commit) 7341547] Initial commit
 1 file changed, 0 insertions(+), 0 deletions(-)
 create mode 100644 Readme.md
$ git push origin master
Counting objects: 3, done.
Writing objects: 100% (3/3), 841 bytes | 0 bytes/s, done.
Total 3 (delta 0), reused 0 (delta 0)
To http://phabricator.dev/diffusion/1/test.git
 * [new branch]      master -> master
```

## Setup Arcanist

The `arc` command line tool is used to create a Diff for code review. 

```bash
./arcanist/bin/arc help
```

Add it to your `$PATH` if you want to make it easier to use:

```
export PATH="$PATH:~/Codez/buildkite-phabricator-dev/arcanist/bin"
```

You'll need to authenticate it:

```bash
$ arc install-certificate http://phabricator.dev/
 CONNECT  Connecting to "http://phabricator.dev/api/"...
LOGIN TO PHABRICATOR
Open this page in your browser and login to Phabricator if necessary:

http://phabricator.dev/conduit/login/

Then paste the API Token on that page below.

    Paste API Token from that page: xxx
Writing ~/.arcrc...
 SUCCESS!  API Token installed.
```

Now you can create your first diff! Going back into the `test` repository:

```bash
cd test
echo '{"phabricator.uri": "http://phabricator.dev/"}' > .arcconfig
git add .
git commit -m "First diff commit"
arc diff
# Note: be sure to add some words to the "Test Plan" section
```

You'll now have your first diff: http://phabricator.dev/D1

## Setup a Harbormaster Build Plan

This is what triggers a Buildkite build.

* Create a Harbormaster build plan: http://phabricator.dev/harbormaster/plan/
* Name: 'Buildkite Test Pipeline'

Now you add a build step:

* Add a build step: http://phabricator.dev/harbormaster/step/new/1/HarbormasterBuildkiteBuildStepImplementation/
* Name: 'Test Pipeline'
* API Token: `xxx` (requires `write_builds` permissions)
* Org name: `xxx`
* Pipeline name: `xxx` (lowercase slug)

### Create a Herald rule to trigger build plans

Herald is used to trigger build plans automatically when new diff revisions are submitted:

* Create a new herald rule: http://phabricator.dev/herald for "Differential Revisions" as "Global"
* Name: 'Trigger a Buildkite diff build'
* Conditions: when 'Repository' 'is any of' 'R1 Test'
* Action: 'Run build plans' 'Plan 1 Buildkite'

Next we create one for when commits are pushed:

* Create a new herald rule: http://phabricator.dev/herald for "Commits" as "Global"
* Name: 'Trigger a Buildkite commit build'
* Conditions: when 'Repository' 'is any of' 'R1 Test'
* Action: 'Run build plans' 'Plan 1 Buildkite'

Now you can create another arc diff, or push a build, and see it trigger harbourmaster builds.

## Send webhooks to Request Bin

If you want to send the Buildkite webhooks to https://requestb.in/, modify the HarbormasterBuildkiteBuildStepImplementation.php like so, and then hit "Restart Build" in Phabricator:

```diff
     $organization = $this->getSetting('organization');
     $pipeline = $this->getSetting('pipeline');
 
-    $uri = urisprintf(
-      'https://api.buildkite.com/v2/organizations/%s/pipelines/%s/builds',
-      $organization,
-      $pipeline);
+    $uri = urisprintf('https://requestb.in/xxx');
 
     $data_structure = array(
       'commit' => $object->getBuildkiteCommit(),
```

## Helpful development snippets

Getting a bash prompt to run phabricator commands:

```bash
docker-compose run --rm phabricator bash
```

Tailing the `phd` worker logs:

```bash
docker-compose exec phabricator tail -f /var/tmp/phd/log/daemons.log
```

## License

MIT (see [LICENSE](LICENSE))