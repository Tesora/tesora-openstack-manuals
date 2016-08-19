#!/bin/bash -xe
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

PUBLISH=$1

if [[ -z "$PUBLISH" ]] ; then
    echo "usage $0 (publish|build)"
    exit 1
fi

# Copy files from draft to named branch and replace all links from
# draft with links to the branch
function copy_to_branch {
    BRANCH=$1

    if [ -e publish-docs/draft ] ; then

        # Copy files over
        mkdir -p publish-docs/$BRANCH
        cp -a publish-docs/draft/* publish-docs/$BRANCH/
        # We don't need this file
        rm -f publish-docs/$BRANCH/draft-index.html
        # We don't need these draft guides on the branch
        rm -rf publish-docs/$BRANCH/arch-design-draft
        rm -rf publish-docs/$BRANCH/ops-guide

        for f in $(find publish-docs/$BRANCH -name "atom.xml"); do
            sed -i -e "s|/draft/|/$BRANCH/|g" $f
        done
        for f in $(find publish-docs/$BRANCH -name "*.html"); do
            sed -i -e "s|/draft/|/$BRANCH/|g" $f
        done
        # Debian Install Guide for Mitaka is not ready
        rm -rf publish-docs/$BRANCH/install-guide-debian
    fi
}

mkdir -p publish-docs

# Build all RST guides
tools/build-all-rst.sh

# Build the www pages so that openstack-doc-test creates a link to
# www/www-index.html.
# Disabled for stable/mitaka:
#if [ "$PUBLISH" = "build" ] ; then
#    python tools/www-generator.py --source-directory www/ \
#        --output-directory publish-docs/www/
#    rsync -a www/static/ publish-docs/www/
#    # publish-docs/www-index.html is the trigger for openstack-indexpage
#    # to include the file.
#    mv publish-docs/www/www-index.html publish-docs/www-index.html
#fi
#if [ "$PUBLISH" = "publish" ] ; then
#    python tools/www-generator.py --source-directory www/ \
#        --output-directory publish-docs
#    rsync -a www/static/ publish-docs/
#    # Don't publish this file
#    rm publish-docs/www-index.html
#fi

if [ "$PUBLISH" = "build" ] ; then
    # Create index page for viewing
    openstack-indexpage publish-docs
fi

# munge the tesora output


cat << EOF > /tmp/extract.py
from bs4 import BeautifulSoup
import sys
soup = BeautifulSoup(file(sys.argv[1]), 'html.parser')
print soup.find(id=sys.argv[2]).parent.parent
EOF

SOURCE="publish-docs/cli-reference/trove.html"
TARGET="publish-docs/cli-reference/tesora-trove.html"
WRAPPER="publish-docs/cli-reference/tesora-trove-iframe.html"

cat << HEADER > $TARGET
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html lang="en" xml:lang="en" xmlns="http://www.w3.org/1999/xhtml">
  <head>
    <meta content="text/html; charset=UTF-8" http-equiv="Content-Type"/>

    <title>OpenStack Docs: Database service command-line client</title>
    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">

<!-- Bootstrap CSS -->
<link href="_static/css/bootstrap.min.css" rel="stylesheet">

<!-- Pygments CSS -->
<link href="_static/css/native.css" rel="stylesheet">

<!-- Fonts -->
<link href="https://maxcdn.bootstrapcdn.com/font-awesome/4.2.0/css/font-awesome.min.css" rel="stylesheet">
<link href='https://fonts.googleapis.com/css?family=Open+Sans:300,400,700' rel='stylesheet' type='text/css'>

<!-- Custom CSS -->
<link href="_static/css/combined.css" rel="stylesheet">
<link href="_static/css/styles.css" rel="stylesheet">

<!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
<!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
<!--[if lt IE 9]>
    <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
    <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
<![endif]-->


</head>
<body>
HEADER

python /tmp/extract.py $SOURCE "database-service-command-line-client" >> $TARGET

cat << FOOTER >> $TARGET
<!-- jQuery -->
<script type="text/javascript" src="_static/js/jquery-1.11.3.js"></script>

<!-- Bootstrap JavaScript -->
<script type="text/javascript" src="_static/js/bootstrap.min.js"></script>

<!-- The rest of the JS -->
<script type="text/javascript" src="_static/js/navigation.js"></script>

<!-- Docs JS -->
<script type="text/javascript" src="_static/js/docs.js"></script>

<!-- Popovers -->
<script type="text/javascript" src="_static/js/webui-popover.js"></script>

<!-- Javascript for page -->
<script language="JavaScript">
/* build a description of this page including SHA, source location on git repo,
   build time and the project's launchpad bug tag. Set the HREF of the bug
   buttons */

    var lineFeed = "%0A";
    var gitURL = "Source: Can't derive source file URL";

    /* there have been cases where "pagename" wasn't set; better check for it */
        /* The URL of the source file on Git is based on the giturl variable
           in conf.py, which must be manually initialized to the source file
           URL in Git.
           "pagename" is a standard sphinx parameter containing the name of
           the source file, without extension.                             */

        var sourceFile = "trove" + ".rst";
        gitURL = "Source: http://git.openstack.org/cgit/openstack/openstack-manuals/tree/doc/cli-reference/source" + "/" + sourceFile;

    /* gitsha, project and bug_tag rely on variables in conf.py */
    var gitSha = "SHA: 7714c362ce2760458e813014841b4321acd161c7";
        var bugProject = "openstack-manuals";
        var bugTitle = "Database service command-line client in Command-Line Interface Reference";
    var fieldTags = "cli-reference";

    /* "last_updated" is the build date and time. It relies on the
       conf.py variable "html_last_updated_fmt", which should include
       year/month/day as well as hours and minutes                   */
    var buildstring = "Release: 0.9 on 2016-08-19 11:25";

    var fieldComment = encodeURI(buildstring) +
                       lineFeed + encodeURI(gitSha) +
                       lineFeed + encodeURI(gitURL) ;

    logABug(bugTitle, bugProject, fieldComment, fieldTags);
</script>

</body>
</html>
FOOTER

cat << IFRAME > $WRAPPER
<iframe frameborder="0" height="650" src="http://docs.elasticdb.org/manuals/$ZUUL_REF/$TARGET" style="" width="100%"> </iframe></p>
IFRAME
