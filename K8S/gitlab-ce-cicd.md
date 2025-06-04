<h1> gitlab-ce cicd </h1>


- [gitlab-ce install](#gitlab-ce-install)
  - [timezone KST](#timezone-kst)
  - [Update System](#update-system)
  - [GitLab CE Repository 추가](#gitlab-ce-repository-추가)
  - [gitlab-ce install](#gitlab-ce-install-1)
  - [gitlab-ce initial configure](#gitlab-ce-initial-configure)
  - [gitlab-ce initial\_root\_passowrd](#gitlab-ce-initial_root_passowrd)

# gitlab-ce install

https://somaz.tistory.com/200

## timezone KST
```
sudo rm -f /etc/localtime
sudo ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime 
```

```
# time sync
time sync
sudo systemctl start chronyd
sudo systemctl enable chronyd
sudo chronyc makestep
```

## Update System ##
```
sudo apt update -y
sudo apt install -y ca-certificates curl openssh-server tzdata
```

## GitLab CE Repository 추가
```
## Install Package ##
sudo apt install curl debian-archive-keyring lsb-release ca-certificates apt-transport-https software-properties-common -y

## run script.deb.sh ##
curl -sS https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/script.deb.sh | sudo bash
```

## gitlab-ce install
```
## Install gitlab-ce https private crt 
# HTTPS_URL='gitlab.example.com'
HTTPS_URL='192.168.61.107'
sudo apt update
sudo -E EXTERNAL_URL="https://$HTTPS_URL/" apt-get install gitlab-ce     # Replace with your Domain
```

## gitlab-ce initial configure
```
sudo mkdir -p /etc/gitlab/
echo "letsencrypt['enable'] = false" | sudo tee -a /etc/gitlab/gitlab.rb
sudo gitlab-ctl reconfigure
sudo gitlab-ctl restart

## gitlab status ##
sudo gitlab-ctl status
```

## gitlab-ce initial_root_passowrd
```
cat /etc/gitlab/initial_root_password
```
```
# WARNING: This value is valid only in the following conditions
#          1. If provided manually (either via `GITLAB_ROOT_PASSWORD` environment variable or via `gitlab_rails['initial_root_password']` setting in `gitlab.rb`, it was provided before database was seeded for the first time (usually, the first reconfigure run).
#          2. Password hasn't been changed manually, either via UI or via command line.
#
#          If the password shown here doesn't work, you must reset the admin password following https://docs.gitlab.com/ee/security/reset_user_password.html#reset-your-root-password.

Password: kOtOjWp7v70OjkjtadnSJAhcDbCNo9nTNGVC5UoSCyE=
```