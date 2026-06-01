# Copyright 2024 Google LLC

# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at

#     https://www.apache.org/licenses/LICENSE-2.0

# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# typical time to build: 10 mins
# typical time to destroy: 8 mins

# === Future enhancements ===
# changes all names
# Github upload
# troubleshoot https://github.com/kurtradecki/gcp-orgpolicies-demo
# Github upload
# refactor fw rules under policies
# Github upload
# refactor to simplify constructs such as multiple subnets, vms, etc
# Github upload
# refactor vpn tunnel names in ncc hybrid spokes ... right now they are hardcoded
# Github upload
# 11) add extra time to wait for apis and org policies to load
# Github upload
# 12) test in new project & revise build timing
# Github upload


project_id                 = "<ENTER PROJECT ID HERE>"
region1                    = "<ENTER 1ST REGION FOR TEST VMs HERE>"
region2                    = "<ENTER 2ND REGION FOR TEST VMs HERE>"
