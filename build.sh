#!/usr/bin/env bash

# we only want to build either master or release tags

IS_RELEASE=true
IS_MASTER=true
IS_PR=true
IS_RELEASE_BUILD=true

[[ "$TRAVIS_TAG" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.RELEASE$ ]] || IS_RELEASE=false
[ "$TRAVIS_BRANCH" = 'master' ] || IS_MASTER=false
[ "$TRAVIS_PULL_REQUEST" != 'false' ] || IS_PR=false

echo IS_MASTER=$IS_MASTER
echo IS_RELEASE=$IS_RELEASE

[[ "$IS_RELEASE" = 'true' || "$IS_MASTER" = 'true' ]] || IS_RELEASE_BUILD=false

echo IS_RELEASE_BUILD=$IS_RELEASE_BUILD

[ "$IS_PR" = 'false' ] || IS_RELEASE_BUILD=false

if [[ "$IS_RELEASE_BUILD" = 'true' ]]; then
    echo ===> Peforming release build

    openssl aes-256-cbc -K $encrypted_c0518a5d8bb7_key -iv $encrypted_c0518a5d8bb7_iv -in gpg.secrets.tar.enc -out gpg.secrets.tar -d
    tar xvf gpg.secrets.tar
    mv id_rsa_travisci ~/.ssh/id_rsa # copy travis-ci-eeichinger ssh key

    mvn deploy -B -Psign --settings settings.xml

    ./publish_docs.sh
else
    echo ===> Performing default build

    mvn install -B
fi
