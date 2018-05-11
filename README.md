<!--
  Licensed to the Apache Software Foundation (ASF) under one or more
  contributor license agreements.  See the NOTICE file distributed with
  this work for additional information regarding copyright ownership.
  The ASF licenses this file to You under the Apache License, Version 2.0
  (the "License"); you may not use this file except in compliance with
  the License.  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
-->

# Docker Image for running secure Apache Hadoop Ozone base image

This is the definition of the Apache Hadoop Ozone base image. It doesn't use any Hadoop distribution just the scripts to run any Hadoop from source or from a prebuild package.



## Usage

Do a full build checkout hadoop repo and build using below maven command.
```
mvn clean install  -Pdist -Phdds -DskipTests=true -Dmaven.javadoc.skip=true -Dtar
```

```
cd dev-support/compose/ozone-secure
docker-compose up -d
```

