### Quickstart:
1. `git submodule update --init`
1. Download and extract a centos 6 x64 PE 3.0.1 tarball to the root directory
1. Verify that the `./pe3` symlink points to the tarball directory
1. `vagrant up` and wait
1. `mco ping` from mcp, m1, m2 or m3 should see four nodes, indicating success.

To verify broken behavior, check out the `0.1.13` tag in the `./pe_mcollective` submodule and `vagrant destroy ; vagrant up`
To vefify fixed behavior, Check out the fixed `pe_mcollective` branch and `vagrant destroy ; vagrant up`
