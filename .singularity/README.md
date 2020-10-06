# .singularity directory

A very small directory to aid in passing host environment variables to the `%post` section.
Typically, this is used to pass secrets in continuous integration environments.

To be clear this is item 1. of this [post](https://github.com/hpcng/singularity/issues/2807#issuecomment-469696535)

## GIT_ASKPASS

From the [cribsheet](https://coolaj86.com/articles/vanilla-devops-git-credentials-cheatsheet/)

`.git-askpass` is an implementation of this.

## Usage

```Singularity
%setup
  # generate .singularity/post-environment _on_ host
  sh .singularity/capture-environment.sh

%files
  # copy files from host
  .singularity/post-environment /root/.singularity-post-environment 
  .singularity/.git-askpass /root/.git-askpass

%post
  # source and remove secrets
  . /root/.singularity-post-environment && rm /root/.singularity-post-environment

  # configure git to use .git-askpass script
  chmod +x /root/.git-askpass
  export GIT_ASKPASS=/root/.git-askpass

  # now askpass is configured cloning is possible
  git clone https://git@github.com/...
  rm $GIT_ASKPASS
```

## See Also

* https://github.com/hpcng/singularity/issues/5270

```
%setup
  sh .singularity/capture-environment.sh > ${SINGULARITY_ROOTFS}/.singularity-post-environment
```
