#!/bin/sh

# Builds a new ansible rpm package from
# https://src.fedoraproject.org/rpms/ansible.git
# in Fedora COPR with
# https://patch-diff.githubusercontent.com/raw/ansible/ansible/pull/56424.patch
# applied

pkg_name=ansible
spec_name=${pkg_name}.spec
local_mirror_base="${HOME}/projects/fedpkg_fedora_pkgs"
local_mirror_path="${local_mirror_base}/${pkg_name}"
spec_patch_file="$(rpm --eval '%{specdir}')/${spec_name}.hostname_f.patch"
copr_repo=misc

# TODO: run `fedpkg clone` unless ${local_mirror_path} exists
cd "${local_mirror_path}"
git pull
patch -i "${spec_patch_file}" -p1 ${spec_name}
# rpmdev-bumpspec produces 'Release: X%{?dist}.Y' instead of 'Release: X.Y%{?dist}
# TODO: report a bug to rpmdevtools upstream
perl -api -e 'next unless $F[0] eq "Release:"; $F[1] =~ /(\d+)(.\d+)?(%.*)?/; $rel = $2 // 0; $rel =~ s/\.//; $F[1] = $1 . "." . ++$rel . $3; $_ = join(" ", @F)' ${spec_name}
# Cannot just use spectool until
# https://bugzilla.redhat.com/show_bug.cgi?id=1711953 is fixed
rpmspec -P ${spec_name} | spectool -g -
fedpkg srpm
copr build ${copr_repo} ${pkg_name}*.src.rpm
git clean -d -f -x
git checkout -- ${spec_name}
