# Sakai Nightly Pipeline
Keep a test server updated.
This project allows you to use a Jenkins server to install a sakai server for testing purposes.

# Installation
- Install Docker.
- Install a Jenkins 2.x server with pipeline plugins (default installation).
- Add _Pipeline Utility_ Steps plugin.
- Add _HTML Publisher_ plugin.
- Create a Multibranch Pipeline job in Jenkins.
- Set this repo url as source url (or your own fork).

# Run
After running master and 11.x branch, you'll have one file for each LOCALE with the patch to apply in Sakai in order to update translations. The job only export reviewed translations from transifex.