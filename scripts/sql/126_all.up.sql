CREATE SEQUENCE IF NOT EXISTS id_seq_terminal_access_templates;

-- Table Definition
CREATE TABLE IF NOT EXISTS "public"."terminal_access_templates"
(
    "id"            integer NOT NULL DEFAULT nextval('id_seq_terminal_access_templates'::regclass),
    "template_name" VARCHAR(1000),
    "template_data" text,
    "created_on"    timestamptz,
    "created_by"    int4,
    "updated_on"    timestamptz,
    "updated_by"    int4,
    PRIMARY KEY ("id")
);

ALTER TABLE ONLY public.terminal_access_templates
    ADD CONSTRAINT terminal_access_template_name_unique UNIQUE (template_name);


CREATE SEQUENCE IF NOT EXISTS id_seq_user_terminal_access_data;

-- Table Definition
CREATE TABLE  IF NOT EXISTS "public"."user_terminal_access_data"
(
    "id"         integer NOT NULL DEFAULT nextval('id_seq_user_terminal_access_data'::regclass),
    "user_id"    int4,
    "cluster_id" integer,
    "pod_name"   VARCHAR(1000),
    "node_name"  VARCHAR(1000),
    "status"     VARCHAR(1000),
    "metadata"   json,
    "created_on" timestamptz,
    "created_by" int4,
    "updated_on" timestamptz,
    "updated_by" int4,
    PRIMARY KEY ("id")
);

ALTER TABLE "public"."user_terminal_access_data"
    ADD FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id");

ALTER TABLE "public"."user_terminal_access_data"
    ADD FOREIGN KEY ("cluster_id") REFERENCES "public"."cluster" ("id");


INSERT into terminal_access_templates(template_name, template_data, created_on, created_by, updated_on, updated_by) VALUES
('terminal-access-service-account','{"apiVersion":"v1","kind":"ServiceAccount","metadata":{"name":"${pod_name}-sa","namespace":"${default_namespace}"}}', now(), 1, now(), 1),
('terminal-access-role-binding','{"apiVersion":"rbac.authorization.k8s.io/v1","kind":"ClusterRoleBinding","metadata":{"name":"${pod_name}-crb"},"subjects":[{"kind":"ServiceAccount","name":"${pod_name}-sa","namespace":"${default_namespace}"}],"roleRef":{"kind":"ClusterRole","name":"cluster-admin","apiGroup":"rbac.authorization.k8s.io"}}', now(), 1, now(), 1),
('terminal-access-pod','{"apiVersion":"v1","kind":"Pod","metadata":{"name":"${pod_name}"},"spec":{"serviceAccountName":"${pod_name}-sa","nodeSelector":{"kubernetes.io/hostname":"${node_name}"},"containers":[{"name":"devtron-debug-terminal","image":"${base_image}","command":["/bin/sh","-c","--"],"args":["while true; do sleep 600; done;"]}],"tolerations":[{"key":"kubernetes.azure.com/scalesetpriority","operator":"Equal","value":"spot","effect":"NoSchedule"}]}}', now(), 1, now(), 1);

INSERT INTO attributes(key, value, active, created_on, created_by, updated_on, updated_by) VALUES ('DEFAULT_TERMINAL_IMAGE_LIST', 'quay.io/devtron/ubuntu-k8s-utils:latest,quay.io/devtron/alpine-k8s-utils:latest,quay.io/devtron/centos-k8s-utils:latest,quay.io/devtron/alpine-netshoot:latest', 't', NOW(), 1,NOW(), 1);INSERT INTO "public"."chart_ref" ("name","location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
    ('Deployment','deployment-chart_1-0-0', '1.0.0','f', 't', 'now()', 1, 'now()', 1);


ALTER TABLE "chart_ref" ADD COLUMN "deployment_strategy_path" text;
ALTER TABLE "chart_ref" ADD COLUMN "json_path_for_strategy" text;
ALTER TABLE "chart_ref" ADD COLUMN "is_app_metrics_supported" bool NOT NULL DEFAULT TRUE;

CREATE SEQUENCE IF NOT EXISTS id_seq_global_strategy_metadata;

CREATE TABLE public.global_strategy_metadata (
"id"                            integer NOT NULL DEFAULT nextval('id_seq_global_strategy_metadata'::regclass),
"name"                          text,
"description"                   text,
"deleted"                       bool NOT NULL DEFAULT FALSE,
"created_on"                    timestamptz,
"created_by"                    int4,
"updated_on"                    timestamptz,
"updated_by"                    int4,
PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_global_strategy_metadata_chart_ref_mapping;

CREATE TABLE public.global_strategy_metadata_chart_ref_mapping (
"id"                            integer NOT NULL DEFAULT nextval('id_seq_global_strategy_metadata_chart_ref_mapping'::regclass),
"global_strategy_metadata_id"   integer,
"chart_ref_id"                  integer,
"active"                        bool NOT NULL DEFAULT TRUE,
"created_on"                    timestamptz,
"created_by"                    int4,
"updated_on"                    timestamptz,
"updated_by"                    int4,
PRIMARY KEY ("id")
);

UPDATE chart_ref set deployment_strategy_path='pipeline-values.yaml' where user_uploaded=false;

UPDATE chart_ref set is_app_metrics_supported=true where version in ('3.7.0','3.8.0','3.9.0','3.10.0','3.11.0','3.12.0','3.13.0','4.10.0','4.11.0','4.12.0','4.13.0','4.14.0','4.15.0','4.16.0','1.0.0') and (name is null or name='Deployment') and user_uploaded=false;

UPDATE chart_ref set is_app_metrics_supported=false where not (version in('3.7.0','3.8.0','3.9.0','3.10.0','3.11.0','3.12.0','3.13.0','4.10.0','4.11.0','4.12.0','4.13.0','4.14.0','4.15.0','4.16.0','1.0.0') and (name is null or name='Deployment')  and user_uploaded=false);

INSERT INTO global_strategy_metadata ("id","name", "description", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
    (1,'ROLLING', 'RollingUpdate or Rolling strategy.', 'false', 'now()', 1, 'now()', 1),
    (2,'BLUE-GREEN', 'Blue green strategy.', 'false', 'now()', 1, 'now()', 1),
    (3,'CANARY', 'Canary strategy.', 'false', 'now()', 1, 'now()', 1),
    (4,'RECREATE', 'Recreate strategy.', 'false', 'now()', 1, 'now()', 1);


SELECT pg_catalog.setval('public.id_seq_global_strategy_metadata', 4, true);

-- for rollout type charts
DO $$
DECLARE
temprow record;
query text;
BEGIN
FOR temprow IN SELECT * FROM chart_ref where version in ('3.2.0','3.3.0','3.4.0','3.5.0','3.6.0','3.7.0','3.8.0','3.9.0','3.10.0','3.11.0','3.12.0','3.13.0','4.10.0','4.11.0','4.12.0','4.13.0','4.14.0','4.15.0','4.16.0') and name is null and user_uploaded=false
	LOOP
                query := E'INSERT INTO global_strategy_metadata_chart_ref_mapping ("global_strategy_metadata_id", "chart_ref_id", "active", "created_on", "created_by", "updated_on", "updated_by") ' ||
                    'VALUES (1,$1, ''true'', ''now()'', 1, ''now()'', 1),' ||
                    '(2,$1, ''true'', ''now()'', 1, ''now()'', 1),' ||
                    '(3,$1, ''true'', ''now()'', 1, ''now()'', 1),' ||
                    '(4,$1, ''true'', ''now()'', 1, ''now()'', 1);';
                EXECUTE query USING temprow.id;
END LOOP;
END$$;

-- for deployment type chart
DO $$
DECLARE
temprow record;
query text;
BEGIN
FOR temprow IN SELECT * FROM chart_ref where version ='1.0.0' and name='Deployment' and user_uploaded=false
    LOOP
                  query := E'INSERT INTO global_strategy_metadata_chart_ref_mapping ("global_strategy_metadata_id", "chart_ref_id", "active", "created_on", "created_by", "updated_on", "updated_by") ' ||
                     'VALUES (1,$1, ''true'', ''now()'', 1, ''now()'', 1),' ||
                     '(4,$1, ''true'', ''now()'', 1, ''now()'', 1);';
                  EXECUTE query USING temprow.id;
END LOOP;
END$$;


-- for non-[deployment,rollout] charts
DO $$
DECLARE
temprow record;
query text;
BEGIN
FOR temprow IN SELECT * FROM chart_ref where not (version in ('3.2.0','3.3.0','3.4.0','3.5.0','3.6.0','3.7.0','3.8.0','3.9.0','3.10.0','3.11.0','3.12.0','3.13.0','4.10.0','4.11.0','4.12.0','4.13.0','4.14.0','4.15.0','4.16.0','1.0.0') and (name is null or name='Deployment')) and user_uploaded=false
    LOOP
                  query := E'INSERT INTO global_strategy_metadata_chart_ref_mapping ("global_strategy_metadata_id", "chart_ref_id", "active", "created_on", "created_by", "updated_on", "updated_by") ' ||
                     'VALUES (1,$1, ''true'', ''now()'', 1, ''now()'', 1),' ||
                      '(2,$1, ''true'', ''now()'', 1, ''now()'', 1);';
                  EXECUTE query USING temprow.id;
END LOOP;
END$$;UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by", "name") VALUES
('cronjob-chart_1-4-0', '1.4.0', 'f', 't', 'now()', 1, 'now()', 1, 'Job & CronJob');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-16-0' AND "version" = '4.16.0';
ALTER table attributes alter column value TYPE character varying(5000);

UPDATE "public"."attributes" SET value = '[{"groupId":"latest","groupRegex":"v1\\.2[4-8]\\..+","imageList":[{"image":"quay.io/devtron/ubuntu-k8s-utils:latest","name":"Ubuntu: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on ubuntu OS"},{"image":"quay.io/devtron/alpine-k8s-utils:latest","name":"Alpine: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on alpine OS"},{"image":"quay.io/devtron/centos-k8s-utils:latest","name":"CentOS: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on Cent OS"},{"image":"quay.io/devtron/alpine-netshoot:latest","name":"Alpine: Netshoot","description":"Contains Docker + Kubernetes network troubleshooting utilities."}]},{"groupId":"v1.22","groupRegex":"v1\\.(21|22|23)\\..+","imageList":[{"image":"quay.io/devtron/ubuntu-k8s-utils:1.22","name":"Ubuntu: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on ubuntu OS"},{"image":"quay.io/devtron/alpine-k8s-utils:1.22","name":"Alpine: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on alpine OS"},{"image":"quay.io/devtron/centos-k8s-utils:1.22","name":"CentOS: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on Cent OS"},{"image":"quay.io/devtron/alpine-netshoot:latest","name":"Alpine: Netshoot","description":"Contains Docker + Kubernetes network troubleshooting utilities."}]},{"groupId":"v1.19","groupRegex":"v1\\.(18|19|20)\\..+","imageList":[{"image":"quay.io/devtron/ubuntu-k8s-utils:1.19","name":"Ubuntu: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on ubuntu OS"},{"image":"quay.io/devtron/alpine-k8s-utils:1.19","name":"Alpine: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on alpine OS"},{"image":"quay.io/devtron/centos-k8s-utils:1.19","name":"CentOS: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on Cent OS"},{"image":"quay.io/devtron/alpine-netshoot:latest","name":"Alpine: Netshoot","description":"Contains Docker + Kubernetes network troubleshooting utilities."}]},{"groupId":"v1.16","groupRegex":"v1\\.(15|16|17)\\..+","imageList":[{"image":"quay.io/devtron/ubuntu-k8s-utils:1.16","name":"Ubuntu: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on ubuntu OS"},{"image":"quay.io/devtron/alpine-k8s-utils:1.16","name":"Alpine: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on alpine OS"},{"image":"quay.io/devtron/centos-k8s-utils:1.16","name":"CentOS: Kubernetes utilites","description":"Contains kubectl, helm, curl, git, busybox, wget, jq, nslookup, telnet on Cent OS"},{"image":"quay.io/devtron/alpine-netshoot:latest","name":"Alpine: Netshoot","description":"Contains Docker + Kubernetes network troubleshooting utilities."}]}]',
                                 updated_on = NOW()
WHERE key = 'DEFAULT_TERMINAL_IMAGE_LIST';INSERT INTO "public"."default_auth_policy" ("id", "role_type", "policy", "created_on", "created_by", "updated_on", "updated_by") VALUES
('8', 'clusterAdmin', '{
    "data": [
        {
            "type": "p",
            "sub": "role:clusterAdmin_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
            "res": "{{.ClusterObj}}/{{.NamespaceObj}}",
            "act": "*",
            "obj": "{{.GroupObj}}/{{.KindObj}}/{{.ResourceObj}}"
        },
        {
            "type": "p",
            "sub": "role:clusterAdmin_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
            "res": "{{.ClusterObj}}/{{.NamespaceObj}}/user",
            "act": "*",
            "obj": "{{.GroupObj}}/{{.KindObj}}/{{.ResourceObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('9', 'clusterEdit', '{
    "data": [
        {
            "type": "p",
            "sub": "role:clusterEdit_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
            "res": "{{.ClusterObj}}/{{.NamespaceObj}}",
            "act": "*",
            "obj": "{{.GroupObj}}/{{.KindObj}}/{{.ResourceObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('10', 'clusterView', '{
    "data": [
        {
            "type": "p",
            "sub": "role:clusterView_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
            "res": "{{.ClusterObj}}/{{.NamespaceObj}}",
            "act": "get",
            "obj": "{{.GroupObj}}/{{.KindObj}}/{{.ResourceObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1');


ALTER TABLE "roles"
    ADD COLUMN "cluster" text,
    ADD COLUMN "namespace" text,
    ADD COLUMN "group" text,
    ADD COLUMN "kind" text,
    ADD COLUMN "resource" text;



INSERT INTO "public"."default_auth_role" ("id", "role_type", "role", "created_on", "created_by", "updated_on", "updated_by") VALUES
('8', 'clusterAdmin', '{
    "role": "role:clusterAdmin_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
    "casbinSubjects": [
        "role:role:clusterAdmin_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}"
    ],
    "entity": "{{.Entity}}",
    "cluster": "{{.Cluster}}",
    "namespace": "{{.Namespace}}",
    "group": "{{.Group}}",
    "kind": "{{.Kind}}",
    "resource": "{{.Resource}}",
    "action": "admin",
    "access_type": ""
}', 'now()', '1', 'now()', '1'),
('9', 'clusterEdit', '{
    "role": "role:clusterEdit_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
    "casbinSubjects": [
        "role:clusterEdit_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}"
    ],
    "entity": "{{.Entity}}",
    "cluster": "{{.Cluster}}",
    "namespace": "{{.Namespace}}",
    "group": "{{.Group}}",
    "kind": "{{.Kind}}",
    "resource": "{{.Resource}}",
    "action": "edit",
    "access_type": ""
}', 'now()', '1', 'now()', '1'),
('10', 'clusterView', '{
    "role": "role:clusterView_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}",
    "casbinSubjects": [
        "role:clusterView_{{.Cluster}}_{{.Namespace}}_{{.Group}}_{{.Kind}}_{{.Resource}}"
    ],
    "entity": "{{.Entity}}",
    "cluster": "{{.Cluster}}",
    "namespace": "{{.Namespace}}",
    "group": "{{.Group}}",
    "kind": "{{.Kind}}",
    "resource": "{{.Resource}}",
    "action": "view",
    "access_type": ""
}', 'now()', '1', 'now()', '1');CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_status_timeline_resources;

CREATE TABLE public.pipeline_status_timeline_resources (
"id"                                integer NOT NULL DEFAULT nextval('id_seq_pipeline_status_timeline_resources'::regclass),
"installed_app_version_history_id"  integer,
"cd_workflow_runner_id"             integer,
"resource_name"                     VARCHAR(1000),
"resource_kind"                     VARCHAR(1000),
"resource_group"                    VARCHAR(1000),
"resource_phase"                    text,
"resource_status"                   text,
"status_message"                    text,
"timeline_stage"                    VARCHAR(100) DEFAULT 'KUBECTL_APPLY',
"created_on"                        timestamptz,
"created_by"                        int4,
"updated_on"                        timestamptz,
"updated_by"                        int4,
CONSTRAINT "pipeline_status_timeline_resources_cd_workflow_runner_id_fkey" FOREIGN KEY ("cd_workflow_runner_id") REFERENCES "public"."cd_workflow_runner" ("id"),
CONSTRAINT "pipeline_status_timeline_resources_installed_app_version_history_id_fkey" FOREIGN KEY ("installed_app_version_history_id") REFERENCES "public"."installed_app_version_history" ("id"),
PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_status_timeline_sync_detail;

CREATE TABLE public.pipeline_status_timeline_sync_detail (
"id"                                integer NOT NULL DEFAULT nextval('id_seq_pipeline_status_timeline_sync_detail'::regclass),
"installed_app_version_history_id"  integer,
"cd_workflow_runner_id"             integer,
"last_synced_at"                    timestamptz,
"sync_count"                        integer,
"created_on"                        timestamptz,
"created_by"                        int4,
"updated_on"                        timestamptz,
"updated_by"                        int4,
 CONSTRAINT "pipeline_status_timeline_sync_detail_cd_workflow_runner_id_fkey" FOREIGN KEY ("cd_workflow_runner_id") REFERENCES "public"."cd_workflow_runner" ("id"),
 CONSTRAINT "pipeline_status_timeline_sync_detail_installed_app_version_history_id_fkey" FOREIGN KEY ("installed_app_version_history_id") REFERENCES "public"."installed_app_version_history" ("id"),
 PRIMARY KEY ("id")
);

ALTER TABLE pipeline ADD COLUMN deployment_app_name text;

DO $$
DECLARE
temprow record;
BEGIN
    FOR temprow IN SELECT p.id, a.app_name, e.environment_name FROM pipeline p INNER JOIN app a on p.app_id = a.id INNER JOIN environment e on p.environment_id = e.id and p.deleted=false
        LOOP
            UPDATE pipeline SET deployment_app_name=FORMAT('%s-%s',temprow.app_name,temprow.environment_name) where id=temprow.id;
        END LOOP;
END$$;

ALTER TABLE cd_workflow_runner ADD COLUMN created_on timestamptz;

ALTER TABLE cd_workflow_runner ADD COLUMN created_by int4;

ALTER TABLE cd_workflow_runner ADD COLUMN updated_on timestamptz;

ALTER TABLE cd_workflow_runner ADD COLUMN updated_by int4;

DO $$
DECLARE
temprow record;
BEGIN
FOR temprow IN SELECT * FROM cd_workflow_runner
    LOOP
UPDATE cd_workflow_runner SET created_on=temprow.started_on, created_by=1, updated_on=temprow.started_on, updated_by=1 where id=temprow.id;
END LOOP;
END$$;do $$
BEGIN
    IF NOT EXISTS (SELECT * FROM plugin_step_variable WHERE name = 'UsePropertiesFileFromProject' AND plugin_step_id = 2) THEN
        INSERT INTO plugin_step_variable (id,plugin_step_id,name,format,description,is_exposed,allow_empty_value,default_value,value,variable_type,value_type,previous_step_index,variable_step_index,variable_step_index_in_plugin,reference_variable_name,deleted,created_on,created_by,updated_on,updated_by) 
        VALUES(nextval('id_seq_plugin_step_variable'),2,'UsePropertiesFileFromProject','BOOL','Boolean value - true or false. Set true to use source code sonar-properties file.','t','f',false,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1);
    END IF;
END;
$$;

INSERT INTO plugin_step_variable (id,plugin_step_id,name,format,description,is_exposed,allow_empty_value,default_value,value,variable_type,value_type,previous_step_index,variable_step_index,variable_step_index_in_plugin,reference_variable_name,deleted,created_on,created_by,updated_on,updated_by) 
VALUES(nextval('id_seq_plugin_step_variable'),2,'CheckForSonarAnalysisReport','BOOL','Boolean value - true or false. Set true to poll for generated report from sonarqube.','t','f',false,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1);

INSERT INTO plugin_step_variable (id,plugin_step_id,name,format,description,is_exposed,allow_empty_value,default_value,value,variable_type,value_type,previous_step_index,variable_step_index,variable_step_index_in_plugin,reference_variable_name,deleted,created_on,created_by,updated_on,updated_by) 
VALUES(nextval('id_seq_plugin_step_variable'),2,'AbortPipelineOnPolicyCheckFailed','BOOL','Boolean value - true or false. Set true to abort on report check failed.','t','f',false,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1);


UPDATE plugin_pipeline_script SET script=E'PathToCodeDir=/devtroncd$CheckoutPath
cd $PathToCodeDir
if [[ -z "$UsePropertiesFileFromProject" || $UsePropertiesFileFromProject == false ]]
then
  echo "sonar.projectKey=$SonarqubeProjectKey" > sonar-project.properties
fi
docker run \\
--rm \\
-e SONAR_HOST_URL=$SonarqubeEndpoint \\
-e SONAR_LOGIN=$SonarqubeApiKey \\
-v "/$PWD:/usr/src" \\
sonarsource/sonar-scanner-cli

if [[ $CheckForSonarAnalysisReport == true && ! -z "$CheckForSonarAnalysisReport" ]]
then
 status=$(curl -u ${SonarqubeApiKey}:  -sS ${SonarqubeEndpoint}/api/qualitygates/project_status?projectKey=${SonarqubeProjectKey}&branch=master)
 project_status=$(echo $status | jq -r  ".projectStatus.status")
 echo "*********  SonarQube Policy Report  *********"
 echo $status
 if [[ $AbortPipelineOnPolicyCheckFailed == true && $project_status == "ERROR" ]]
 then
  echo "*********  SonarQube Policy Violated *********"
  echo "*********  Exiting Build *********"
  exit
 elif [[ $AbortPipelineOnPolicyCheckFailed == true && $project_status == "OK" ]]
 then
  echo "*********  SonarQube Policy Passed *********"
 fi
fi' WHERE id=2;CREATE SEQUENCE IF NOT EXISTS id_seq_k8s_resource_history_sequence;

-- Table Definition
CREATE TABLE IF NOT EXISTS "public"."kubernetes_resource_history"
(
    "id"            integer NOT NULL DEFAULT nextval('id_seq_k8s_resource_history_sequence'::regclass),
    "app_id"  integer,
    "app_name" VARCHAR(100),
    "env_id"  integer,
    "namespace"  VARCHAR(100) ,
    "resource_name" VARCHAR(100),
    "kind"    VARCHAR(100),
    "group"    VARCHAR(100),
    "force_delete"   boolean,
    "action_type"   VARCHAR(100),
    "deployment_app_type"  VARCHAR(100),
    "created_on"    timestamptz,
    "created_by"    int4,
    "updated_on"    timestamptz,
    "updated_by"    int4,
    PRIMARY KEY ("id")
    );INSERT INTO "plugin_metadata" ("id", "name", "description","type","icon","deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES (nextval('id_seq_plugin_metadata'), 'Semgrep','Semgrep is a fast, open source, static analysis engine for finding bugs, detecting dependency vulnerabilities, and enforcing code standards.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/semgrep.png','f', 'now()', 1, 'now()', 1);

INSERT INTO "plugin_tag_relation" ("id", "tag_id", "plugin_id", "created_on", "created_by", "updated_on", "updated_by") VALUES (nextval('id_seq_plugin_tag_relation'), 2, (SELECT id FROM plugin_metadata WHERE name='Semgrep'),'now()', 1, 'now()', 1);
INSERT INTO "plugin_tag_relation" ("id", "tag_id", "plugin_id", "created_on", "created_by", "updated_on", "updated_by") VALUES (nextval('id_seq_plugin_tag_relation'), 3, (SELECT id FROM plugin_metadata WHERE name='Semgrep'),'now()', 1, 'now()', 1);

INSERT INTO "plugin_pipeline_script" ("id", "script","type","deleted","created_on", "created_by", "updated_on", "updated_by")
VALUES (
    nextval('id_seq_plugin_pipeline_script'),
    '#!/bin/sh
set -eo pipefail
chmod 741 /devtroncd
chmod 741 /devtroncd/*
apk add py3-pip
pip install pip==21.3.1
pip install semgrep
export SEMGREP_APP_TOKEN=$SemgrepAppToken
SemgrepTokenLen=$(echo -n $SEMGREP_APP_TOKEN | wc -m)
if [ $((SemgrepTokenLen)) == 0 ]
then
    SEMGREP_APP_TOKEN=$SEMGREP_API_TOKEN
fi
CiMaterialsEnv=$GIT_MATERIAL_REQUEST
repoName=""
checkoutPath=""
branchName=""
gitHash=""
materials=$(echo $CiMaterialsEnv | tr "|" "\n")
for material in $materials
do
    data=$(echo $material | tr "," "\n")
    i=0
    for d in $data
    do
        if [ $((i)) == 0 ]
        then
            repoName=$d
        elif [ $((i)) == 1 ]
        then
            checkoutPath=$d
        elif [ $((i)) == 2 ]
        then
            branchName=$d
        elif [ $((i)) == 3 ]
        then
            gitHash=$d
        fi
        i=$((i+1))
    done
    #docker run --rm --env SEMGREP_APP_TOKEN=$SemgrepAppToken --env SEMGREP_REPO_NAME=$repoName --env SEMGREP_BRANCH=$branchName -v "${PWD}/:/src/" returntocorp/semgrep semgrep ci
    cd /devtroncd
    cd $checkoutPath
    export SEMGREP_REPO_NAME=$repoName
    if [ $UseCommitAsSemgrepBranchName == true -a $PrefixAppNameInSemgrepBranchName == true ]
    then
        export SEMGREP_BRANCH="$SemgrepAppName - $gitHash"
    elif [ $PrefixAppNameInSemgrepBranchName == true ]
    then
        export SEMGREP_BRANCH="$SemgrepAppName - $branchName"
    elif [ $UseCommitAsSemgrepBranchName == true ]
    then
        export SEMGREP_BRANCH=$gitHash
    else
        export SEMGREP_BRANCH=$branchName
    fi
    semgrep ci --json $ExtraCommandArguments
done'
        ,
    'SHELL',
    'f',
    'now()',
    1,
    'now()',
    1
);

INSERT INTO "plugin_step" ("id", "plugin_id","name","description","index","step_type","script_id","deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES (nextval('id_seq_plugin_step'), (SELECT id FROM plugin_metadata WHERE name='Semgrep'),'Step 1','Step 1 - Dependency Track for Semgrep','1','INLINE',(SELECT last_value FROM id_seq_plugin_pipeline_script),'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "variable_type", "value_type", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Semgrep' and ps."index"=1 and ps.deleted=false), 'SemgrepAppToken','STRING','If provided, this token will be used. If not provided it will be picked from secret.',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Semgrep' and ps."index"=1 and ps.deleted=false), 'PrefixAppNameInSemgrepBranchName','BOOL','if true, this will add app name with branch name: {SemgrepAppName}-{branchName}.',true,false,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Semgrep' and ps."index"=1 and ps.deleted=false), 'UseCommitAsSemgrepBranchName','BOOL','if true, this will add app name with commit hash: {SemgrepAppName}-{CommitHash}',true,false,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Semgrep' and ps."index"=1 and ps.deleted=false), 'SemgrepAppName','STRING','if provided and PrefixAppNameInSemgrepBranchName is true, then this will be prefixed with branch name/ commit hash',true,false,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Semgrep' and ps."index"=1 and ps.deleted=false), 'ExtraCommandArguments','STRING','Extra Command arguments for semgrep CI command. eg input: --json --dry-run.',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Semgrep' and ps."index"=1 and ps.deleted=false), 'GIT_MATERIAL_REQUEST','STRING','git material data',false,true,3,'INPUT','GLOBAL',1 ,'GIT_MATERIAL_REQUEST','f','now()', 1, 'now()', 1);

INSERT INTO plugin_metadata (id,name,description,type,icon,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_metadata'),'Codacy','Codacy is an automated code analysis/quality tool that helps developers ship better software, faster.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/codacy-plugin-icon.png',false,'now()',1,'now()',1);

INSERT INTO plugin_pipeline_script (id,script,type,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_pipeline_script'),E'if [[ ! -z "$CodacyApiToken" ]]
then
  CODACY_API_TOKEN=$CodacyApiToken
fi
data_raw="{\\\"branchName\\\":\\\"$Branch\\\",\\\"categories\\\":[\\\"Security\\\"],\\\"levels\\\":[\\\"Error\\\"]}"
raw_url="curl -X POST \\\"$CodacyEndpoint/api/v3/analysis/organizations/$GitProvider/$Organisation/repositories/$RepoName/issues/search\\\" -H \\\"Content-Type:application/json\\\" -H \\\"api-token:$CODACY_API_TOKEN\\\" --data-raw \'$data_raw\'"
result=`eval $raw_url`
echo $result
export NUMBER_OF_ISSUES=$(echo $result | jq -r ".data | length")
echo "***********number of issue***********"
echo "Number of issues are: $NUMBER_OF_ISSUES"
echo "***********number of issue***********"
if [ "$NUMBER_OF_ISSUES" -gt "0" ]
then
    echo "This code has critical Vulnerabilities . Visit https://app.codacy.com/gh/delhivery/$REPO/issues  for more Info"
else
    exit 0
fi','SHELL',false,'now()',1,'now()',1);

INSERT INTO plugin_step (id,plugin_id,name,description,index,step_type,script_id,ref_plugin_id,output_directory_path,dependent_on_step,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_step'),(SELECT id FROM plugin_metadata WHERE name='Codacy'),'Step 1','Step 1 for Codacy',1,'INLINE',(SELECT last_value FROM id_seq_plugin_pipeline_script),null,null,null,false,'now()',1,'now()',1);

INSERT INTO plugin_step_variable (id,plugin_step_id,name,format,description,is_exposed,allow_empty_value,default_value,value,variable_type,value_type,previous_step_index,variable_step_index,variable_step_index_in_plugin,reference_variable_name,deleted,created_on,created_by,updated_on,updated_by) 
VALUES (nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'CodacyEndpoint','STRING','Api Endpoint for Codacy','t','f',null,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1),
(nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'GitProvider','STRING','Git provider for the scan','t','f',null,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1),
(nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'CodacyApiToken','STRING','If provided, this token will be used. If not provided it will be picked from global secret(CODACY_API_TOKEN)','t','t',null,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1),
(nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'Organisation','STRING','Org for the Codacy','t','f',null,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1),
(nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'RepoName','STRING','Repo name','t','f',false,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1),
(nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'Branch','STRING','Branch name ','t','f',null,null,'INPUT','NEW',null,1,null,null,'f','now()',1,'now()',1),
(nextval('id_seq_plugin_step_variable'),(SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Codacy' and ps."index"=1 and ps.deleted=false),'NUMBER_OF_ISSUES','STRING','Number of issue in code source','t','f',false,null,'OUTPUT','NEW',null,1,null,null,'f','now()',1,'now()',1);


INSERT INTO plugin_tag (id,name,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_tag'),'Code Review',false,'now()',1,'now()',1);

INSERT INTO plugin_tag_relation (id,tag_id,plugin_id,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_tag_relation'),2,(SELECT id FROM plugin_metadata WHERE name='Codacy'),'now()',1,'now()',1),
(nextval('id_seq_plugin_tag_relation'),3,(SELECT id FROM plugin_metadata WHERE name='Codacy'),'now()',1,'now()',1),
(nextval('id_seq_plugin_tag_relation'),(SeLECT id FROM plugin_tag WHERE name='Code Review'),(SELECT id FROM plugin_metadata WHERE name='Codacy'),'now()',1,'now()',1);
UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_3-10-0', '3.10.0', 't', 't', 'now()', '1', 'now()', '1');INSERT INTO "public"."chart_ref" ("name","location", "version", "deployment_strategy_path","is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
     ('Deployment','deployment-chart_1-1-0', '1.1.0','pipeline-values.yaml','f', 't', 'now()', 1, 'now()', 1);

INSERT INTO global_strategy_metadata_chart_ref_mapping ("global_strategy_metadata_id", "chart_ref_id", "active", "created_on", "created_by", "updated_on", "updated_by")
VALUES (1,(select id from chart_ref where version='1.1.0' and name='Deployment'), true, now(), 1, now(), 1),
(4,(select id from chart_ref where version='1.1.0' and name='Deployment'), true, now(), 1, now(), 1);UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version","deployment_strategy_path", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
    ('reference-chart_4-17-0', '4.17.0','pipeline-values.yaml', 't', 't', 'now()', 1, 'now()', 1);


INSERT INTO global_strategy_metadata_chart_ref_mapping ("global_strategy_metadata_id", "chart_ref_id", "active", "created_on", "created_by", "updated_on", "updated_by")
VALUES (1,(select id from chart_ref where version='4.17.0' and name is null), true, now(), 1, now(), 1),
(2,(select id from chart_ref where version='4.17.0' and name is null), true, now(), 1, now(), 1),
(3,(select id from chart_ref where version='4.17.0' and name is null), true, now(), 1, now(), 1),
(4,(select id from chart_ref where version='4.17.0' and name is null), true, now(), 1, now(), 1);CREATE TABLE public.app_status
(
    "app_id" integer,
    "env_id" integer,
    "status" varchar(50),
    "updated_on" timestamp with time zone NOT NULL,
    PRIMARY KEY ("app_id","env_id"),
    CONSTRAINT app_status_app_id_fkey
        FOREIGN KEY(app_id)
            REFERENCES public.app(id),
    CONSTRAINT app_status_env_id_fkey
        FOREIGN KEY(env_id)
            REFERENCES public.environment(id)

)ALTER TABLE app_label ADD COLUMN IF NOT EXISTS propagate boolean NOT NULL DEFAULT true;

ALTER TABLE "public"."app_label" ALTER COLUMN "key" SET DATA TYPE varchar(317);-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_global_tag;

-- Table Definition
CREATE TABLE IF NOT EXISTS "public"."global_tag"
(
    "id"                        int4         NOT NULL DEFAULT nextval('id_seq_global_tag'::regclass),
    "key"                       varchar(100) NOT NULL,
    "mandatory_project_ids_csv" varchar(100),
    "propagate"                 bool,
    "description"               TEXT         NOT NULL,
    "active"                    bool,
    "created_on"                timestamptz  NOT NULL,
    "created_by"                int4         NOT NULL,
    "updated_on"                timestamptz,
    "updated_by"                int4,
    PRIMARY KEY ("id")
);INSERT INTO plugin_metadata (id,name,description,type,icon,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_metadata'),'Jira Issue Validator','This plugin extends the filtering capabilities of the Devtron CI and lets the users perform validation based on JIRA Ticket ID status.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/plugin-jira.png',false,'now()',1,'now()',1);

INSERT INTO "plugin_pipeline_script" ("id", "script","type","deleted","created_on", "created_by", "updated_on", "updated_by")
VALUES (
   nextval('id_seq_plugin_pipeline_script'),
   '#!/bin/sh
# step-1 -> find the jira issue
echo -e "\033[1m======== Finding the Jira issue ========"
curl -u $JiraUsername:$JiraPassword $JiraBaseUrl/rest/api/2/issue/$JiraId > jira_issue_search_result.txt

if [ $? != 0 ]; then
   echo -e "\033[1m======== Finding the jira issue failed ========"
   exit 1
fi

# step-2 -> converting to JSON
echo "Converting to json result"
cat jira_issue_search_result.txt | jq > jira_issue_search_result_json.txt

if [ $? != 0 ]; then
   echo -e "\033[1m======== Converting to json result failed ========"
   exit 1
fi

# step-3 -> Find the error message from JSON result
echo "Finding the error message from JSON result"
jq ".errorMessages" jira_issue_search_result_json.txt > error_message.txt
jq ".fields.status.statusCategory.name" jira_issue_search_result_json.txt > jira_issue_status_category_name.txt

if [ $? != 0 ]; then
   echo -e "\033[1m======== Finding the error message from JSON result failed ========"
   exit 1
fi

# step-4 -> check if error message if null or not
echo "checking if error message is not null"

if [ null == "$(cat error_message.txt)" ] ;then
    echo -e "\033[1m======== Jira issue exists ========"
    echo "validating jira issue status"
    if [ "\"Done\"" == "$(cat jira_issue_status_category_name.txt)" ] ;then
        echo -e "\033[1m======== Jira issue is in closed state ========"
        exit 1
    else
        echo -e "\033[1m======== Jira issue is not in closed state ========"
    fi
else
    echo -e "\033[1m======== Jira issue does not exist ========"
    exit 1
fi
'
   ,
   'SHELL',
   'f',
   'now()',
   1,
   'now()',
   1
);

INSERT INTO "plugin_step" ("id", "plugin_id","name","description","index","step_type","script_id","deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_step'), (SELECT id FROM plugin_metadata WHERE name='Jira Issue Validator'),'Step 1','Step 1 - Jira Issue Validator','1','INLINE',(SELECT last_value FROM id_seq_plugin_pipeline_script),'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "variable_type", "value_type", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Validator' and ps."index"=1 and ps.deleted=false), 'JiraUsername','STRING','Username of Jira account',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Validator' and ps."index"=1 and ps.deleted=false), 'JiraPassword','STRING','Password of Jira account',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Validator' and ps."index"=1 and ps.deleted=false), 'JiraBaseUrl','STRING','Base Url of Jira account',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Validator' and ps."index"=1 and ps.deleted=false), 'JiraId','STRING','Jira Id',false,true,3,'INPUT','GLOBAL',1 ,'JIRA_ID','f','now()', 1, 'now()', 1);INSERT INTO plugin_metadata (id,name,description,type,icon,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_metadata'),'Jira Issue Updater','This plugin extends the capabilities of Devtron CI and can update issues in JIRA by adding pipeline status and metadata as comment on the tickets.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/plugin-jira.png',false,'now()',1,'now()',1);

INSERT INTO "plugin_pipeline_script" ("id", "script","type","deleted","created_on", "created_by", "updated_on", "updated_by")
VALUES (
   nextval('id_seq_plugin_pipeline_script'),
   '#!/bin/sh
if [[ $UpdateWithBuildStatus == true ]]
then
	# step-1 -> updating the jira issue with build status
	echo -e "\033[1m======== Updating the Jira issue with build status ========"
    buildStatusMessage="Failed"
    if [[ $BuildSuccess == true ]]
    then
        buildStatusMessage="Succeeded"
    fi
	curl -u $JiraUsername:$JiraPassword -X PUT $JiraBaseUrl/rest/api/2/issue/$JiraId -H "Content-Type: application/json" -d ''{"update": {"comment": [{"add":{"body":"''"Build status : $buildStatusMessage"''"}}]}}''

	if [ $? != 0 ]; then
	   echo -e "\033[1m======== Updating the jira Jira with build status failed ========"
	   exit 1
	fi
fi

if [[ $UpdateWithDockerImageId == true && $BuildSuccess == true ]]
then
	# step-2 -> updating the jira issue with docker image Id
	echo -e "\033[1m======== Updating the Jira issue with docker image Id ========"
	curl -u $JiraUsername:$JiraPassword -X PUT $JiraBaseUrl/rest/api/2/issue/$JiraId -H "Content-Type: application/json" -d ''{"update": {"comment": [{"add":{"body":"''"Image built : $DockerImage"''"}}]}}''

	if [ $? != 0 ]; then
	   echo -e "\033[1m======== Updating the jira Jira with docker image Id failed ========"
	   exit 1
	fi
fi
'
   ,
   'SHELL',
   'f',
   'now()',
   1,
   'now()',
   1
);

INSERT INTO "plugin_step" ("id", "plugin_id","name","description","index","step_type","script_id","deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_step'), (SELECT id FROM plugin_metadata WHERE name='Jira Issue Updater'),'Step 1','Step 1 - Jira Issue Updater','1','INLINE',(SELECT last_value FROM id_seq_plugin_pipeline_script),'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "variable_type", "value_type", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'JiraUsername','STRING','Username of Jira account',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'JiraPassword','STRING','Password of Jira account',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'JiraBaseUrl','STRING','Base Url of Jira account',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "default_value", "variable_type", "value_type", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'UpdateWithDockerImageId','BOOL','If true - Jira Issue will be updated with docker image Id in comment. Default: true',true,true, true, 'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'UpdateWithBuildStatus','BOOL','If true - Jira Issue will be updated with build status in comment. Default: true',true,true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'JiraId','STRING','Jira Id',false,true,3,'INPUT','GLOBAL',1 ,'JIRA_ID','f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'DockerImage','STRING','Docker Image',false,true,3,'INPUT','GLOBAL',1 ,'DOCKER_IMAGE','f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false), 'BuildSuccess','BOOL','Build Success',false,true,3,'INPUT','GLOBAL',1 ,'BUILD_SUCCESS','f','now()', 1, 'now()', 1);ALTER TABLE "public"."pipeline" ADD COLUMN deployment_app_delete_request bool DEFAULT false;
ALTER TABLE "public"."installed_apps" ADD COLUMN deployment_app_delete_request bool DEFAULT false;

update pipeline set deployment_app_delete_request=true
where deleted=true AND deployment_app_type='argo_cd' AND deployment_app_created=true;

update installed_apps set deployment_app_delete_request=true
where active=true AND deployment_app_type='argo_cd';
update pipeline set deployment_app_delete_request=true
where deleted=true AND deployment_app_type='argo_cd' AND deployment_app_created=false;

update installed_apps set deployment_app_delete_request=false
where active=true AND deployment_app_type='argo_cd';

update installed_apps set deployment_app_delete_request=true
where active=false AND deployment_app_type='argo_cd';INSERT INTO plugin_metadata (id,name,description,type,icon,deleted,created_on,created_by,updated_on,updated_by)
VALUES (nextval('id_seq_plugin_metadata'),'Github Pull Request Updater','This plugin extends the capabilities of Devtron CI and can update pull requests in GITHUB by adding pipeline status and metadata as comment.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/plugin-github-pr.png',false,'now()',1,'now()',1);

INSERT INTO "plugin_pipeline_script" ("id", "script","type","deleted","created_on", "created_by", "updated_on", "updated_by")
VALUES (
   nextval('id_seq_plugin_pipeline_script'),
   '#!/bin/sh
if [[ $UpdateWithBuildStatus == true ]]
then
	# step-1 -> updating the PR with build status
	echo -e "\033[1m======== Commenting build status in PR ========"
    buildStatusMessage="Failed"
    if [[ $BuildSuccess == true ]]
    then
        buildStatusMessage="Succeeded"
    fi
	curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $AccessToken" -H "X-GitHub-Api-Version: 2022-11-28" $CommentsUrl -d ''{"body": "''"Build status : $buildStatusMessage"''"}''

	if [ $? != 0 ]; then
	   echo -e "\033[1m======== Updating the PR with build status failed ========"
	   exit 1
	fi
fi

if [[ $UpdateWithDockerImageId == true && $BuildSuccess == true ]]
then
	# step-2 -> updating the PR with docker image Id
	echo -e "\033[1m======== Commenting docker image Id in PR ========"
    curl -X POST -H "Accept: application/vnd.github+json" -H "Authorization: Bearer $AccessToken" -H "X-GitHub-Api-Version: 2022-11-28" $CommentsUrl -d ''{"body": "''"Image built : $DockerImage"''"}''

	if [ $? != 0 ]; then
	   echo -e "\033[1m======== Updating the PR with docker image Id failed ========"
	   exit 1
	fi
fi
'
   ,
   'SHELL',
   'f',
   'now()',
   1,
   'now()',
   1
);

INSERT INTO "plugin_step" ("id", "plugin_id","name","description","index","step_type","script_id","deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_step'), (SELECT id FROM plugin_metadata WHERE name='Github Pull Request Updater'),'Step 1','Step 1 - Github Pull Request Updater','1','INLINE',(SELECT last_value FROM id_seq_plugin_pipeline_script),'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "variable_type", "value_type", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false), 'AccessToken','STRING','Personal access token which will be used to authenticating to Github APIs for this plugin',true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "default_value", "variable_type", "value_type", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false), 'UpdateWithDockerImageId','BOOL','If true - PR will be updated with docker image Id in comment. Default: true',true,true, true, 'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1),
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false), 'UpdateWithBuildStatus','BOOL','If true - PR will be updated with build status in comment. Default: true',true,true,true,'INPUT','NEW',1 ,'f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false), 'CommentsUrl','STRING','Comments url',false,true,3,'INPUT','GLOBAL',1 ,'COMMENTS_URL','f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false), 'DockerImage','STRING','Docker Image',false,true,3,'INPUT','GLOBAL',1 ,'DOCKER_IMAGE','f','now()', 1, 'now()', 1);

INSERT INTO "plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value","value","variable_type", "value_type", "variable_step_index",reference_variable_name, "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
(nextval('id_seq_plugin_step_variable'), (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false), 'BuildSuccess','BOOL','Build Success',false,true,3,'INPUT','GLOBAL',1 ,'BUILD_SUCCESS','f','now()', 1, 'now()', 1);UPDATE "public"."chart_repo" SET "auth_mode" = 'ANONYMOUS' WHERE "id" in (1,2,3,4);---- add trigger_if_parent_stage_fail column
ALTER TABLE pipeline_stage_step ADD COLUMN IF NOT EXISTS trigger_if_parent_stage_fail bool;ALTER table global_cm_cs ADD secret_ingestion_for VARCHAR(50);
--setting type as CI/CD because secrets until this release should be available in both CI and CD pipelines
UPDATE global_cm_cs SET secret_ingestion_for='CI/CD';ALTER TABLE app ADD COLUMN IF NOT EXISTS app_type integer not null DEFAULT 0;
UPDATE app SET app_type = CASE WHEN app_store = false THEN 0 WHEN app_store = true THEN 1 ELSE app_type  END;
ALTER TABLE app ADD COLUMN IF NOT EXISTS description text;
ALTER TABLE app ADD COLUMN IF NOT EXISTS display_name varchar(250);
ALTER TABLE ci_artifact ADD COLUMN IF NOT EXISTS is_artifact_uploaded BOOLEAN DEFAULT FALSE;
UPDATE ci_artifact SET is_artifact_uploaded = true;


ALTER table installed_apps ADD COLUMN notes text;

UPDATE "public"."default_auth_role"
SET role= '{
    "role": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:manager_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "manager",
    "entity": "{{.Entity}}",
    "accessType": "devtron-app"
}'
WHERE role_type='manager' AND id=1;

UPDATE "public"."default_auth_role"
SET role= '{
    "role": "role:admin_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:admin_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "admin",
    "entity": "{{.Entity}}",
    "accessType": "devtron-app"
}'
WHERE role_type='admin' AND id =2;

UPDATE "public"."default_auth_role"
SET role= '{
    "role": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:trigger_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "trigger",
    "entity": "{{.Entity}}",
    "accessType": "devtron-app"
}'
WHERE role_type='trigger' AND id =3;

UPDATE "public"."default_auth_role"
SET role= '{
    "role": "role:view_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:view_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "view",
    "entity": "{{.Entity}}",
    "accessType": "devtron-app"
}'
WHERE role_type='view' AND id =4;

ALTER TABLE "public"."default_auth_policy"
    ADD COLUMN access_type varchar(50);

ALTER TABLE "public"."default_auth_policy"
    ADD COLUMN entity varchar(50);

UPDATE "public"."default_auth_policy"
SET entity = 'apps', access_type ='devtron-app'
WHERE role_type = 'manager'OR  role_type = 'trigger' OR  role_type = 'view'OR  role_type ='admin';

UPDATE "public"."default_auth_policy"
SET entity = 'cluster', role_type='edit'
WHERE role_type = 'clusterEdit';

UPDATE "public"."default_auth_policy"
SET entity = 'cluster', role_type='view'
WHERE role_type = 'clusterView';

UPDATE "public"."default_auth_policy"
SET entity = 'cluster', role_type='admin'
WHERE role_type = 'clusterAdmin';

UPDATE "public"."default_auth_policy"
SET entity = 'chart-group', role_type='update'
WHERE role_type = 'entitySpecific';

UPDATE "public"."default_auth_policy"
SET entity = 'chart-group', role_type='view'
WHERE role_type = 'entityView';

UPDATE "public"."default_auth_policy"
SET entity = 'chart-group', role_type='admin'
WHERE role_type = 'entityAll';


SELECT setval('id_seq_default_auth_policy', (SELECT MAX(id) FROM default_auth_policy));

INSERT INTO "public"."default_auth_policy" ( "role_type", "policy", "created_on", "created_by", "updated_on", "updated_by","access_type","entity") VALUES
                                                                                                                                     ( 'admin', '{
    "data": [
         {
            "type": "p",
            "sub": "helm-app:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "helm-app",
            "act": "*",
            "obj": "{{.TeamObj}}/{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "get",
            "obj": "{{.TeamObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "get",
            "obj": "{{.EnvObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1','helm-app','apps'),
                                                                                                                                     ('edit', '{
    "data": [
        {
            "type": "p",
            "sub": "helm-app:edit_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "helm-app",
            "act": "get",
            "obj": "{{.TeamObj}}/{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:edit_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "helm-app",
            "act": "update",
            "obj": "{{.TeamObj}}/{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:edit_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "get",
            "obj": "{{.EnvObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:edit_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "get",
            "obj": "{{.TeamObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1','helm-app','apps'),
                                                                                                                                     ('view', '{
    "data": [
         {
            "type": "p",
            "sub": "helm-app:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "helm-app",
            "act": "get",
            "obj": "{{.TeamObj}}/{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "get",
            "obj": "{{.EnvObj}}"
        },
        {
            "type": "p",
            "sub": "helm-app:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "get",
            "obj": "{{.TeamObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1','helm-app','apps');


ALTER TABLE "public"."default_auth_role"
    ADD COLUMN access_type varchar(50);

ALTER TABLE "public"."default_auth_role"
    ADD COLUMN entity varchar(50);

UPDATE "public"."default_auth_role"
SET access_type = 'devtron-app' , entity  ='apps'
WHERE role_type = 'manager'OR  role_type = 'trigger' OR  role_type = 'view'OR  role_type ='admin';



UPDATE "public"."default_auth_role"
SET entity = 'cluster', role_type='edit'
WHERE role_type = 'clusterEdit';

UPDATE "public"."default_auth_role"
SET entity = 'cluster', role_type='view'
WHERE role_type = 'clusterView';

UPDATE "public"."default_auth_role"
SET entity = 'cluster', role_type='admin'
WHERE role_type = 'clusterAdmin';



UPDATE "public"."default_auth_role"
SET entity = 'chart-group', role_type='view'
WHERE role_type = 'entitySpecificView';

UPDATE "public"."default_auth_role"
SET entity = 'chart-group', role_type='update'
WHERE role_type = 'roleSpecific';

UPDATE "public"."default_auth_role"
SET entity = 'chart-group', role_type='admin'
WHERE role_type = 'entitySpecificAdmin';



SELECT setval('id_seq_default_auth_role', (SELECT MAX(id) FROM default_auth_role));



INSERT INTO "public"."default_auth_role" ( "role_type", "role", "created_on", "created_by", "updated_on", "updated_by","access_type","entity") VALUES
                                                                                                                                 ( 'admin', '{
    "role": "helm-app:admin_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects":
    [
        "helm-app:admin_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "admin",
    "entity": "{{.Entity}}",
    "accessType": "helm-app"
}', 'now()', '1', 'now()', '1','helm-app','apps'),
                                                                                                                                 ( 'edit', '{
   "role": "helm-app:edit_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects":
    [
        "helm-app:edit_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "edit",
    "entity": "{{.Entity}}",
    "accessType": "helm-app"
}', 'now()', '1', 'now()', '1','helm-app','apps'),
                                                                                                                                 ( 'view', '{
     "role": "helm-app:view_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects":
    [
        "helm-app:view_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "view",
    "entity": "{{.Entity}}",
    "accessType": "helm-app"
}', 'now()', '1', 'now()', '1','helm-app','apps');


ALTER TABLE "public"."global_tag" ALTER COLUMN "key" SET DATA TYPE varchar(317);ALTER TABLE ONLY public.app DROP CONSTRAINT app_app_name_key;UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_3-11-0', '3.11.0', 't', 't', 'now()', '1', 'now()', '1');
ALTER TABLE gitops_config ADD COLUMN azure_project character varying(250);-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_bulk_update_readme;

-- Table Definition
CREATE TABLE "public"."bulk_update_readme" (
                                               "id" int4 NOT NULL DEFAULT nextval('id_seq_bulk_update_readme'::regclass),
                                               "resource" varchar(255) NOT NULL,
                                               "readme" text,
                                               "script" jsonb,
                                               PRIMARY KEY ("id")
);

INSERT INTO "public"."bulk_update_readme" ("id", "resource", "readme", "script") VALUES
    (1, 'v1beta1/application', '# Bulk Update - Application
This feature helps you to update deployment template for multiple apps in one go! You can filter the apps on the basis of environments, global flag, and app names(we provide support for both substrings included and excluded in the app name).
## Example
Example below will select all applications having `abc and xyz` present in their name and out of those will exclude applications having `abcd and xyza` in their name. Since global flag is false and envId 23 is provided, it will make changes in envId 23 and not in global deployment template for this application.
If you want to update global deployment template then please set `global: true`.  If you have provided envId by deployment template is not overridden for that particular environment then it will not apply the changes.
```
apiVersion: batch/v1beta1
kind: Application
spec:
  includes:
    names:
    - "%abc%"
    - "%xyz%"
  excludes:
    names:
    - "%abcd%"
    - "%xyza%"
  envIds:
  - 23
  global: false
  deploymentTemplate:
    spec:
      patchJson: ''[{ "op": "add", "path": "/MaxSurge", "value": 1 },{"op": "replace","path":"/GracePeriod","value": "30"}]''
```
## Payload Configuration
The following tables list the configurable parameters of the Payload component in the Script and their description along with example.
| Parameter                      | Description                        | Example                                                    |
| -------------------------- | ---------------------------------- | ---------------------------------------------------------- |
|`includes.names `        | Will filter apps having exact string or similar substrings                 | `["app%","%abc", "xyz"]` (will include all apps having `"app%"` **OR** `"%abc"` as one of their substring, example - app1, app-test, test-abc etc. **OR** application with name xyz)    |
| `excludes.names`          | Will filter apps not having exact string or similar substrings.              | `["%z","%y", "abc"]`       (will filter out all apps having `"%z"` **OR** `"%y"` as one of their substring, example - appz, test-app-y etc. **OR** application with name abc)                                        |
| `envIds`       | List of envIds to be updated for the selected applications           | `[1,2,3]`                                                   |
| `global`       | Flag to update global deployment template of applications            | `true`,`false`                                                        |
| `patchJson`      | String having the update operation(you can apply more than one changes at a time). It supports [JSON patch ](http://jsonpatch.com/) specifications for update. | `''[ { "op": "add", "path": "/MaxSurge", "value": 1 }, { "op": "replace", "path": "/GracePeriod", "value": "30" }]''` |
', '{"kind": "Application", "spec": {"envIds": [1, 2, 3], "global": false, "excludes": {"names": ["%xyz%"]}, "includes": {"names": ["%abc%"]}, "deploymentTemplate": {"spec": {"patchJson": "Enter Patch String"}}}, "apiVersion": "core/v1beta1"}');

CREATE INDEX ON bulk_update_readme (resource);
CREATE INDEX "cdwf_pipeline_id_idx" ON "public"."cd_workflow" USING BTREE ("pipeline_id");
CREATE INDEX "pco_pipeline_id_idx" ON "public"."pipeline_config_override" USING BTREE ("pipeline_id");
CREATE INDEX "cdwfr_cd_workflow_id_idx" ON "public"."cd_workflow_runner" USING BTREE ("cd_workflow_id");ALTER TABLE "public"."image_scan_deploy_info" DROP CONSTRAINT IF EXISTS "image_scan_deploy_info_scan_object_meta_id_fkey";UPDATE "public"."bulk_update_readme"
SET "script" = '{"kind": "Application", "spec": {"envIds": [1, 2, 3], "global": false, "excludes": {"names": ["%xyz%"]}, "includes": {"names": ["%abc%"]}, "deploymentTemplate": {"spec": {"patchJson": "Enter Patch String"}}, "configMap": {"spec": { "names": ["abc"],"patchJson": "Enter Patch String"}},"secret": {"spec": { "names": ["abc"],"patchJson": "Enter Patch String"}}}, "apiVersion": "core/v1beta1"}',
"readme" = '# Bulk Update - Application

This feature helps you to update Deployment Template, ConfigMaps & Secrets for multiple apps in one go! You can filter the apps on the basis of environments, global flag, and app names(we provide support for both substrings included and excluded in the app name).

## Example

Example below will select all applications having `abc and xyz` present in their name and out of those will exclude applications having `abcd and xyza` in their name. Since global flag is false and envId 23 is provided, it will make changes in envId 23 and not in global deployment template for this application.

If you want to update globally then please set `global: true`. If you have provided envId by deployment template, configMap or secret is not overridden for that particular environment then it will not apply the changes.
Also, of all the provided names of configMaps/secrets, for every app & environment override only the name that are present in them will be considered.

```
apiVersion: batch/v1beta1
kind: Application
spec:
  includes:
    names:
    - "%abc%"
    - "%xyz%"
  excludes:
    names:
    - "%abcd%"
    - "%xyza%"
  envIds:
  - 23
  global: false
  deploymentTemplate:
    spec:
      patchJson: ''[{ "op": "add", "path": "/MaxSurge", "value": 1 },{"op": "replace","path":"/GracePeriod","value": "30"}]''
  configMap:
    spec:
      names:
      - "configmap1"
      - "configmap2"
      - "configmap3"
      patchJson: ''[{ "op": "add", "path": "/{key}", "value": "{value}" },{"op": "replace","path":"/{key}","value": "{value}"}]''
  secret:
    spec:
      names:
      - "secret1"
      - "secret2"
      patchJson: ''[{ "op": "add", "path": "/{key}", "value": "{value}" },{"op": "replace","path":"/{key}","value": "{value}"}]''
```

## Payload Configuration


The following tables list the configurable parameters of the Payload component in the Script and their description along with example. Also, if you do not need to apply updates on all the tasks, i.e. Deployment Template, ConfigMaps & Secrets, leave the Spec object empty for that respective task.

| Parameter                      | Description                        | Example                                                    |
| -------------------------- | ---------------------------------- | ---------------------------------------------------------- |
|`includes.names `        | Will filter apps having exact string or similar substrings                 | `["app%","%abc", "xyz"]` (will include all apps having `"app%"` **OR** `"%abc"` as one of their substring, example - app1, app-test, test-abc etc. **OR** application with name xyz)    |
| `excludes.names`          | Will filter apps not having exact string or similar substrings.              | `["%z","%y", "abc"]`       (will filter out all apps having `"%z"` **OR** `"%y"` as one of their substring, example - appz, test-app-y etc. **OR** application with name abc)                                        |
| `envIds`       | List of envIds to be updated for the selected applications.           | `[1,2,3]`                                                   |
| `global`       | Flag to update global deployment template of applications.            | `true`,`false`                                                        |
| `deploymentTemplate.spec.patchJson`       | String having the update operation(you can apply more than one changes at a time). It supports [JSON patch ](http://jsonpatch.com/) specifications for update. | `''[ { "op": "add", "path": "/MaxSurge", "value": 1 }, { "op": "replace", "path": "/GracePeriod", "value": "30" }]''` |
| `configMap.spec.names`      | Names of all ConfigMaps to be updated. | `configmap1`,`configmap2`,`configmap3` |
| `secret.spec.names`      | Names of all Secrets to be updated. | `secret1`,`secret2`|
| `configMap.spec.patchJson` / `secret.spec.patchJson`       | String having the update operation for ConfigMaps/Secrets(you can apply more than one changes at a time). It supports [JSON patch ](http://jsonpatch.com/) specifications for update. | `''[{ "op": "add", "path": "/{key}", "value": "{value}" },{"op": "replace","path":"/{key}","value": "{value}"}]''`(Replace the `{key}` part to the key you want to perform operation on & the `{value}`is the key''s corresponding value |
' WHERE "id" = 1;--
-- Name: git_host_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.git_host_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: git_host; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.git_host (
     id INTEGER NOT NULL DEFAULT nextval('git_host_id_seq'::regclass),
     name character varying(250) NOT NULL,
     active bool NOT NULL,
     webhook_url character varying(500),
     webhook_secret character varying(250),
     event_type_header character varying(250),
     secret_header character varying(250),
     secret_validator character varying(250),
     created_on timestamptz NOT NULL,
     created_by INTEGER NOT NULL,
     updated_on timestamptz,
     updated_by INTEGER,
     PRIMARY KEY ("id"),
     UNIQUE(name)
);


---- Insert master data into git_host
INSERT INTO git_host (name, created_on, created_by, active, webhook_url, webhook_secret, event_type_header, secret_header, secret_validator)
VALUES ('Github', NOW(), 1, 't', '/orchestrator/webhook/git/1', MD5(random()::text), 'X-GitHub-Event', 'X-Hub-Signature' , 'SHA-1'),
       ('Bitbucket Cloud', NOW(), 1, 't', '/orchestrator/webhook/git/2/' || MD5(random()::text), NULL, 'X-Event-Key', NULL, 'URL_APPEND');


---- add column in git_provider (git_host.id)
ALTER TABLE git_provider
    ADD COLUMN git_host_id INTEGER;



---- Add Foreign key constraint on git_host_id in Table git_provider
ALTER TABLE git_provider
    ADD CONSTRAINT git_host_id_fkey FOREIGN KEY (git_host_id) REFERENCES public.git_host(id);


---- update notification template for CI trigger stack
UPDATE notification_templates
set template_payload = '{
    "text": ":arrow_forward: Build pipeline Triggered |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":arrow_forward: *Build Pipeline triggered*\n{{eventTime}} \n Triggered by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url": "https://github.com/devtron-labs/notifier/assets/image/img_build_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Pipeline*\n{{pipelineName}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "actions",
            "elements": [{
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "View Details"
                }
                {{#buildHistoryLink}}
                    ,
                    "url": "{{& buildHistoryLink}}"
                {{/buildHistoryLink}}
            }]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CI'
and event_type_id = 1;


---- update notification template for CI success stack
UPDATE notification_templates
set template_payload = '{
  "text": ":tada: Build pipeline Successful |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "\n"
      }
    },
    {
      "type": "divider"
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ":tada: *Build Pipeline successful*\n{{eventTime}} \n Triggered by {{triggeredBy}}"
      },
      "accessory": {
        "type": "image",
        "image_url": "https://github.com/devtron-labs/notifier/assets/image/img_build_notification.png",
        "alt_text": "calendar thumbnail"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Application*\n{{appName}}"
        },
        {
          "type": "mrkdwn",
          "text": "*Pipeline*\n{{pipelineName}}"
        }
      ]
    },
    {{#ciMaterials}}
    {{^webhookType}}
    {
    "type": "section",
    "fields": [
        {
          "type": "mrkdwn",
           "text": "*Branch*\n`{{appName}}/{{branch}}`"
        },
        {
          "type": "mrkdwn",
          "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
        }
    ]
    },
    {{/webhookType}}
    {{#webhookType}}
    {{#webhookData.mergedType}}
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Title*\n{{webhookData.data.title}}"
        },
        {
        "type": "mrkdwn",
        "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
        }
    ]
    },
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
        },
        {
        "type": "mrkdwn",
        "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
        }
    ]
    },
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
        },
        {
        "type": "mrkdwn",
        "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
        }
    ]
    },
    {{/webhookData.mergedType}}
    {{^webhookData.mergedType}}
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
        }
    ]
    },
    {{/webhookData.mergedType}}
    {{/webhookType}}
    {{/ciMaterials}}
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "View Details"
          }
          {{#buildHistoryLink}}
            ,
            "url": "{{& buildHistoryLink}}"
          {{/buildHistoryLink}}
        }
      ]
    }
  ]
}'
where channel_type = 'slack'
and node_type = 'CI'
and event_type_id = 2;



---- update notification template for CI fail stack
UPDATE notification_templates
set template_payload = '{
    "text": ":x: Build pipeline Failed |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":x: *Build Pipeline failed*\n{{eventTime}} \n Triggered by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url": "https://github.com/devtron-labs/notifier/assets/image/img_build_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Pipeline*\n{{pipelineName}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "actions",
            "elements": [{
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "View Details"
                }
                  {{#buildHistoryLink}}
                    ,
                    "url": "{{& buildHistoryLink}}"
                   {{/buildHistoryLink}}
            }]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CI'
and event_type_id = 3;


---- update notification template for CD trigger stack
UPDATE notification_templates
set template_payload = '{
    "text": ":arrow_forward: Deployment pipeline Triggered |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":arrow_forward: *Deployment Pipeline triggered on {{envName}}*\n{{eventTime}} \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/notifier/assets/image/img_deployment_notification.png",
                "alt_text": "Deploy Pipeline Triggered"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
             "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CD'
and event_type_id = 1;



---- update notification template for CD success stack
UPDATE notification_templates
set template_payload = '{
    "text": ":tada: Deployment pipeline Successful |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":tada: *Deployment Pipeline successful on {{envName}}*\n{{eventTime}} \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/notifier/assets/image/img_deployment_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
             "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CD'
and event_type_id = 2;


---- update notification template for CD fail stack
UPDATE notification_templates
set template_payload = '{
    "text": ":x: Deployment pipeline Failed |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":x: *Deployment Pipeline failed on {{envName}}*\n{{eventTime}} \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/notifier/assets/image/img_deployment_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CD'
and event_type_id = 3;--
-- PostgreSQL database dump
--

-- Dumped from database version 11.3
-- Dumped by pg_dump version 11.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app (
    id integer NOT NULL,
    app_name character varying(250) NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    team_id integer,
    app_store boolean DEFAULT false
);


ALTER TABLE public.app OWNER TO postgres;

--
-- Name: app_env_linkouts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_env_linkouts (
    id integer NOT NULL,
    app_id integer,
    environment_id integer,
    link text,
    description text,
    name character varying(100) NOT NULL,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer
);


ALTER TABLE public.app_env_linkouts OWNER TO postgres;

--
-- Name: app_env_linkouts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_env_linkouts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_env_linkouts_id_seq OWNER TO postgres;

--
-- Name: app_env_linkouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_env_linkouts_id_seq OWNED BY public.app_env_linkouts.id;


--
-- Name: app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_id_seq OWNER TO postgres;

--
-- Name: app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_id_seq OWNED BY public.app.id;


--
-- Name: app_level_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_level_metrics (
    id integer NOT NULL,
    app_id integer NOT NULL,
    app_metrics boolean NOT NULL,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    infra_metrics boolean DEFAULT true
);


ALTER TABLE public.app_level_metrics OWNER TO postgres;

--
-- Name: app_level_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_level_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_level_metrics_id_seq OWNER TO postgres;

--
-- Name: app_level_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_level_metrics_id_seq OWNED BY public.app_level_metrics.id;


--
-- Name: app_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_store (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    chart_repo_id integer,
    active boolean NOT NULL,
    chart_git_location character varying(250),
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL
);


ALTER TABLE public.app_store OWNER TO postgres;

--
-- Name: app_store_application_version; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_store_application_version (
    id integer NOT NULL,
    version character varying(250),
    app_version character varying(250),
    created timestamp with time zone,
    deprecated boolean,
    description text,
    digest character varying(250),
    icon character varying(250),
    name character varying(100),
    home character varying(100),
    source character varying(250),
    values_yaml json NOT NULL,
    chart_yaml json NOT NULL,
    app_store_id integer,
    latest boolean DEFAULT false,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    raw_values text,
    readme text,
    created_by integer,
    updated_by integer
);


ALTER TABLE public.app_store_application_version OWNER TO postgres;

--
-- Name: app_store_application_version_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_store_application_version_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_store_application_version_id_seq OWNER TO postgres;

--
-- Name: app_store_application_version_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_store_application_version_id_seq OWNED BY public.app_store_application_version.id;


--
-- Name: app_store_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_store_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_store_id_seq OWNER TO postgres;

--
-- Name: app_store_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_store_id_seq OWNED BY public.app_store.id;


--
-- Name: app_store_version_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_store_version_values (
    id integer NOT NULL,
    name character varying(100),
    values_yaml text NOT NULL,
    app_store_application_version_id integer,
    deleted boolean DEFAULT false NOT NULL,
    created_by integer,
    updated_by integer,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    reference_type character varying(50)
);


ALTER TABLE public.app_store_version_values OWNER TO postgres;

--
-- Name: app_store_version_values_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_store_version_values_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_store_version_values_id_seq OWNER TO postgres;

--
-- Name: app_store_version_values_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_store_version_values_id_seq OWNED BY public.app_store_version_values.id;


--
-- Name: app_workflow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_workflow (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    app_id integer NOT NULL,
    workflow_dag text,
    active boolean,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer
);


ALTER TABLE public.app_workflow OWNER TO postgres;

--
-- Name: app_workflow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_workflow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_workflow_id_seq OWNER TO postgres;

--
-- Name: app_workflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.app_workflow_id_seq OWNED BY public.app_workflow.id;


--
-- Name: app_workflow_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.app_workflow_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.app_workflow_mapping_id_seq OWNER TO postgres;

--
-- Name: app_workflow_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.app_workflow_mapping (
    id integer DEFAULT nextval('public.app_workflow_mapping_id_seq'::regclass) NOT NULL,
    type character varying(100),
    component_id integer,
    parent_id integer,
    app_workflow_id integer NOT NULL,
    active boolean,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    parent_type character varying(100)
);


ALTER TABLE public.app_workflow_mapping OWNER TO postgres;

--
-- Name: casbin_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.casbin_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.casbin_id_seq OWNER TO postgres;

--
-- Name: casbin_role_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.casbin_role_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.casbin_role_id_seq OWNER TO postgres;

--
-- Name: cd_workflow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cd_workflow (
    id integer NOT NULL,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    ci_artifact_id integer NOT NULL,
    pipeline_id integer NOT NULL,
    workflow_status character varying(256)
);


ALTER TABLE public.cd_workflow OWNER TO postgres;

--
-- Name: cd_workflow_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cd_workflow_config (
    id integer NOT NULL,
    cd_timeout integer,
    min_cpu character varying(256),
    max_cpu character varying(256),
    min_mem character varying(256),
    max_mem character varying(256),
    min_storage character varying(256),
    max_storage character varying(256),
    min_eph_storage character varying(256),
    max_eph_storage character varying(256),
    cd_cache_bucket character varying(256),
    cd_cache_region character varying(256),
    cd_image character varying(256),
    wf_namespace character varying(256),
    cd_pipeline_id integer,
    logs_bucket character varying(256),
    cd_artifact_location_format character varying(256)
);


ALTER TABLE public.cd_workflow_config OWNER TO postgres;

--
-- Name: cd_workflow_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cd_workflow_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cd_workflow_config_id_seq OWNER TO postgres;

--
-- Name: cd_workflow_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cd_workflow_config_id_seq OWNED BY public.cd_workflow_config.id;


--
-- Name: cd_workflow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cd_workflow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cd_workflow_id_seq OWNER TO postgres;

--
-- Name: cd_workflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cd_workflow_id_seq OWNED BY public.cd_workflow.id;


--
-- Name: cd_workflow_runner; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cd_workflow_runner (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    workflow_type character varying(256) NOT NULL,
    executor_type character varying(256) NOT NULL,
    status character varying(256),
    pod_status character varying(256),
    message character varying(256),
    started_on timestamp with time zone,
    finished_on timestamp with time zone,
    namespace character varying(256),
    log_file_path character varying(256),
    triggered_by integer,
    cd_workflow_id integer NOT NULL
);


ALTER TABLE public.cd_workflow_runner OWNER TO postgres;

--
-- Name: cd_workflow_runner_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cd_workflow_runner_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cd_workflow_runner_id_seq OWNER TO postgres;

--
-- Name: cd_workflow_runner_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cd_workflow_runner_id_seq OWNED BY public.cd_workflow_runner.id;


--
-- Name: chart_env_config_override; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chart_env_config_override (
    id integer NOT NULL,
    chart_id integer,
    target_environment integer,
    env_override_yaml text NOT NULL,
    status character varying(50) NOT NULL,
    reviewed boolean NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    namespace character varying(250),
    latest boolean DEFAULT false NOT NULL,
    previous boolean DEFAULT false NOT NULL,
    is_override boolean
);


ALTER TABLE public.chart_env_config_override OWNER TO postgres;

--
-- Name: chart_env_config_override_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chart_env_config_override_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chart_env_config_override_id_seq OWNER TO postgres;

--
-- Name: chart_env_config_override_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chart_env_config_override_id_seq OWNED BY public.chart_env_config_override.id;


--
-- Name: chart_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chart_group (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    description text,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.chart_group OWNER TO postgres;

--
-- Name: chart_group_deployment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chart_group_deployment (
    id integer NOT NULL,
    chart_group_id integer NOT NULL,
    chart_group_entry_id integer,
    installed_app_id integer NOT NULL,
    group_installation_id character varying(250),
    deleted boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.chart_group_deployment OWNER TO postgres;

--
-- Name: chart_group_deployment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chart_group_deployment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chart_group_deployment_id_seq OWNER TO postgres;

--
-- Name: chart_group_deployment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chart_group_deployment_id_seq OWNED BY public.chart_group_deployment.id;


--
-- Name: chart_group_entry; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chart_group_entry (
    id integer NOT NULL,
    app_store_values_version_id integer,
    app_store_application_version_id integer,
    chart_group_id integer,
    deleted boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.chart_group_entry OWNER TO postgres;

--
-- Name: chart_group_entry_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chart_group_entry_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chart_group_entry_id_seq OWNER TO postgres;

--
-- Name: chart_group_entry_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chart_group_entry_id_seq OWNED BY public.chart_group_entry.id;


--
-- Name: chart_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chart_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chart_group_id_seq OWNER TO postgres;

--
-- Name: chart_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chart_group_id_seq OWNED BY public.chart_group.id;


--
-- Name: id_seq_chart_ref; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seq_chart_ref
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_seq_chart_ref OWNER TO postgres;

--
-- Name: chart_ref; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chart_ref (
    id integer DEFAULT nextval('public.id_seq_chart_ref'::regclass) NOT NULL,
    location character varying(250),
    version character varying(250),
    is_default boolean,
    active boolean,
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer
);


ALTER TABLE public.chart_ref OWNER TO postgres;

--
-- Name: chart_repo; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chart_repo (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    url character varying(250) NOT NULL,
    is_default boolean NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    external boolean DEFAULT false
);


ALTER TABLE public.chart_repo OWNER TO postgres;

--
-- Name: chart_repo_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chart_repo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.chart_repo_id_seq OWNER TO postgres;

--
-- Name: chart_repo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chart_repo_id_seq OWNED BY public.chart_repo.id;


--
-- Name: charts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.charts (
    id integer NOT NULL,
    app_id integer,
    chart_repo_id integer,
    chart_name character varying(250) NOT NULL,
    chart_version character varying(250) NOT NULL,
    chart_repo character varying(250) NOT NULL,
    chart_repo_url character varying(250) NOT NULL,
    git_repo_url character varying(250) NOT NULL,
    chart_location character varying(250) NOT NULL,
    status character varying(50) NOT NULL,
    active boolean NOT NULL,
    reference_template character varying(250) NOT NULL,
    values_yaml text NOT NULL,
    global_override text NOT NULL,
    environment_override text,
    release_override text NOT NULL,
    user_overrides text,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    image_descriptor_template text,
    latest boolean DEFAULT false NOT NULL,
    chart_ref_id integer NOT NULL,
    pipeline_override text DEFAULT '{}'::text NOT NULL,
    previous boolean DEFAULT false NOT NULL
);


ALTER TABLE public.charts OWNER TO postgres;

--
-- Name: charts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.charts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.charts_id_seq OWNER TO postgres;

--
-- Name: charts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.charts_id_seq OWNED BY public.charts.id;


--
-- Name: ci_artifact; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_artifact (
    id integer NOT NULL,
    image character varying(250),
    image_digest character varying(250),
    material_info text,
    data_source character varying(50),
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    pipeline_id integer,
    ci_workflow_id integer,
    parent_ci_artifact integer,
    scan_enabled boolean DEFAULT false NOT NULL,
    scanned boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ci_artifact OWNER TO postgres;

--
-- Name: ci_artifact_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_artifact_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_artifact_id_seq OWNER TO postgres;

--
-- Name: ci_artifact_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_artifact_id_seq OWNED BY public.ci_artifact.id;


--
-- Name: ci_pipeline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_pipeline (
    id integer NOT NULL,
    app_id integer,
    ci_template_id integer,
    name character varying(250),
    version character varying(250),
    active boolean NOT NULL,
    deleted boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    manual boolean DEFAULT false NOT NULL,
    external boolean DEFAULT false,
    docker_args text,
    parent_ci_pipeline integer,
    scan_enabled boolean DEFAULT false NOT NULL
);


ALTER TABLE public.ci_pipeline OWNER TO postgres;

--
-- Name: ci_pipeline_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_pipeline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_pipeline_id_seq OWNER TO postgres;

--
-- Name: ci_pipeline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_pipeline_id_seq OWNED BY public.ci_pipeline.id;


--
-- Name: ci_pipeline_material; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_pipeline_material (
    id integer NOT NULL,
    git_material_id integer,
    ci_pipeline_id integer,
    path character varying(250),
    checkout_path character varying(250),
    type character varying(250),
    value character varying(250),
    scm_id character varying(250),
    scm_name character varying(250),
    scm_version character varying(250),
    active boolean,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.ci_pipeline_material OWNER TO postgres;

--
-- Name: ci_pipeline_material_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_pipeline_material_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_pipeline_material_id_seq OWNER TO postgres;

--
-- Name: ci_pipeline_material_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_pipeline_material_id_seq OWNED BY public.ci_pipeline_material.id;


--
-- Name: ci_pipeline_scripts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_pipeline_scripts (
    id integer NOT NULL,
    name character varying(256) NOT NULL,
    index integer NOT NULL,
    ci_pipeline_id integer NOT NULL,
    script text,
    stage character varying(256),
    output_location character varying(256),
    active boolean,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer
);


ALTER TABLE public.ci_pipeline_scripts OWNER TO postgres;

--
-- Name: ci_pipeline_scripts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_pipeline_scripts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_pipeline_scripts_id_seq OWNER TO postgres;

--
-- Name: ci_pipeline_scripts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_pipeline_scripts_id_seq OWNED BY public.ci_pipeline_scripts.id;


--
-- Name: ci_template; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_template (
    id integer NOT NULL,
    app_id integer,
    docker_registry_id character varying(250),
    docker_repository character varying(250),
    dockerfile_path character varying(250),
    args text,
    before_docker_build text,
    after_docker_build text,
    template_name character varying(250),
    version character varying(250),
    active boolean,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    git_material_id integer
);


ALTER TABLE public.ci_template OWNER TO postgres;

--
-- Name: ci_template_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_template_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_template_id_seq OWNER TO postgres;

--
-- Name: ci_template_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_template_id_seq OWNED BY public.ci_template.id;


--
-- Name: ci_workflow; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_workflow (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    status character varying(50),
    pod_status character varying(50),
    message character varying(250),
    started_on timestamp with time zone,
    finished_on timestamp with time zone,
    namespace character varying(250),
    log_file_path character varying(250),
    git_triggers json,
    triggered_by integer NOT NULL,
    ci_pipeline_id integer NOT NULL,
    ci_artifact_location character varying(256)
);


ALTER TABLE public.ci_workflow OWNER TO postgres;

--
-- Name: ci_workflow_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ci_workflow_config (
    id integer NOT NULL,
    ci_timeout bigint,
    min_cpu character varying(250),
    max_cpu character varying(250),
    min_mem character varying(250),
    max_mem character varying(250),
    min_storage character varying(250),
    max_storage character varying(250),
    min_eph_storage character varying(250),
    max_eph_storage character varying(250),
    ci_cache_bucket character varying(250),
    ci_cache_region character varying(250),
    ci_image character varying(250),
    wf_namespace character varying(250),
    logs_bucket character varying(250),
    ci_pipeline_id integer NOT NULL,
    ci_artifact_location_format character varying(256)
);


ALTER TABLE public.ci_workflow_config OWNER TO postgres;

--
-- Name: ci_workflow_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_workflow_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_workflow_config_id_seq OWNER TO postgres;

--
-- Name: ci_workflow_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_workflow_config_id_seq OWNED BY public.ci_workflow_config.id;


--
-- Name: ci_workflow_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ci_workflow_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ci_workflow_id_seq OWNER TO postgres;

--
-- Name: ci_workflow_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ci_workflow_id_seq OWNED BY public.ci_workflow.id;


--
-- Name: cluster; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cluster (
    id integer NOT NULL,
    cluster_name character varying(250) NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    server_url character varying(250),
    config json,
    prometheus_endpoint character varying(250),
    cd_argo_setup boolean DEFAULT false,
    p_username character varying(250),
    p_password character varying(250),
    p_tls_client_cert text,
    p_tls_client_key text
);


ALTER TABLE public.cluster OWNER TO postgres;

--
-- Name: cluster_accounts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cluster_accounts (
    id integer NOT NULL,
    account character varying(250) NOT NULL,
    config json NOT NULL,
    cluster_id integer NOT NULL,
    namespace character varying(250) NOT NULL,
    is_default boolean DEFAULT false,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.cluster_accounts OWNER TO postgres;

--
-- Name: cluster_accounts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cluster_accounts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cluster_accounts_id_seq OWNER TO postgres;

--
-- Name: cluster_accounts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cluster_accounts_id_seq OWNED BY public.cluster_accounts.id;


--
-- Name: cluster_helm_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cluster_helm_config (
    id integer NOT NULL,
    cluster_id integer NOT NULL,
    tiller_url character varying(250),
    tiller_cert character varying,
    tiller_key character varying,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.cluster_helm_config OWNER TO postgres;

--
-- Name: cluster_helm_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cluster_helm_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cluster_helm_config_id_seq OWNER TO postgres;

--
-- Name: cluster_helm_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cluster_helm_config_id_seq OWNED BY public.cluster_helm_config.id;


--
-- Name: cluster_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cluster_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cluster_id_seq OWNER TO postgres;

--
-- Name: cluster_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.cluster_id_seq OWNED BY public.cluster.id;


--
-- Name: cluster_installed_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cluster_installed_apps_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cluster_installed_apps_id_seq OWNER TO postgres;

--
-- Name: cluster_installed_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cluster_installed_apps (
    id integer DEFAULT nextval('public.cluster_installed_apps_id_seq'::regclass) NOT NULL,
    cluster_id integer,
    installed_app_id integer,
    created_by integer,
    created_on timestamp with time zone,
    updated_by integer,
    updated_on timestamp with time zone
);


ALTER TABLE public.cluster_installed_apps OWNER TO postgres;

--
-- Name: id_seq_config_map_app_level; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seq_config_map_app_level
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_seq_config_map_app_level OWNER TO postgres;

--
-- Name: config_map_app_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.config_map_app_level (
    id integer DEFAULT nextval('public.id_seq_config_map_app_level'::regclass),
    app_id integer NOT NULL,
    config_map_data text,
    secret_data text,
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer
);


ALTER TABLE public.config_map_app_level OWNER TO postgres;

--
-- Name: id_seq_config_map_env_level; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seq_config_map_env_level
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_seq_config_map_env_level OWNER TO postgres;

--
-- Name: config_map_env_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.config_map_env_level (
    id integer DEFAULT nextval('public.id_seq_config_map_env_level'::regclass),
    app_id integer NOT NULL,
    environment_id integer NOT NULL,
    config_map_data text,
    secret_data text,
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer
);


ALTER TABLE public.config_map_env_level OWNER TO postgres;

--
-- Name: id_seq_config_map_pipeline_level; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seq_config_map_pipeline_level
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_seq_config_map_pipeline_level OWNER TO postgres;

--
-- Name: config_map_pipeline_level; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.config_map_pipeline_level (
    id integer DEFAULT nextval('public.id_seq_config_map_pipeline_level'::regclass),
    app_id integer NOT NULL,
    environment_id integer NOT NULL,
    pipeline_id integer NOT NULL,
    config_map_data text,
    secret_data text,
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer
);


ALTER TABLE public.config_map_pipeline_level OWNER TO postgres;

--
-- Name: cve_policy_control_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.cve_policy_control_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.cve_policy_control_id_seq OWNER TO postgres;

--
-- Name: cve_policy_control; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cve_policy_control (
    id integer DEFAULT nextval('public.cve_policy_control_id_seq'::regclass) NOT NULL,
    global boolean,
    cluster_id integer,
    env_id integer,
    app_id integer,
    cve_store_id character varying(255),
    action integer,
    severity integer,
    deleted boolean,
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer
);


ALTER TABLE public.cve_policy_control OWNER TO postgres;

--
-- Name: cve_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cve_store (
    name character varying(255) NOT NULL,
    severity integer,
    package character varying(255),
    version character varying(255),
    fixed_version character varying(255),
    created_on timestamp with time zone,
    created_by integer,
    updated_on timestamp with time zone,
    updated_by integer
);


ALTER TABLE public.cve_store OWNER TO postgres;

--
-- Name: db_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_config (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    type character varying(250) NOT NULL,
    host character varying(250) NOT NULL,
    port character varying(250) NOT NULL,
    db_name character varying(250) NOT NULL,
    user_name character varying(250) NOT NULL,
    password character varying(250) NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.db_config OWNER TO postgres;

--
-- Name: db_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.db_config_id_seq OWNER TO postgres;

--
-- Name: db_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_config_id_seq OWNED BY public.db_config.id;


--
-- Name: db_migration_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.db_migration_config (
    id integer NOT NULL,
    db_config_id integer NOT NULL,
    pipeline_id integer NOT NULL,
    git_material_id integer NOT NULL,
    script_source character varying(250) NOT NULL,
    migration_tool character varying(250) NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.db_migration_config OWNER TO postgres;

--
-- Name: db_migration_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.db_migration_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.db_migration_config_id_seq OWNER TO postgres;

--
-- Name: db_migration_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.db_migration_config_id_seq OWNED BY public.db_migration_config.id;


--
-- Name: deployment_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deployment_group (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    status character varying(50),
    app_count integer,
    no_of_apps text,
    environment_id integer,
    ci_pipeline_id integer,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.deployment_group OWNER TO postgres;

--
-- Name: deployment_group_app; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deployment_group_app (
    id integer NOT NULL,
    deployment_group_id integer,
    app_id integer,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.deployment_group_app OWNER TO postgres;

--
-- Name: deployment_group_app_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deployment_group_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deployment_group_app_id_seq OWNER TO postgres;

--
-- Name: deployment_group_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deployment_group_app_id_seq OWNED BY public.deployment_group_app.id;


--
-- Name: deployment_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deployment_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deployment_group_id_seq OWNER TO postgres;

--
-- Name: deployment_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deployment_group_id_seq OWNED BY public.deployment_group.id;


--
-- Name: deployment_status; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.deployment_status (
    id integer NOT NULL,
    app_name character varying(250) NOT NULL,
    status character varying(50) NOT NULL,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    app_id integer,
    env_id integer
);


ALTER TABLE public.deployment_status OWNER TO postgres;

--
-- Name: deployment_status_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.deployment_status_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.deployment_status_id_seq OWNER TO postgres;

--
-- Name: deployment_status_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.deployment_status_id_seq OWNED BY public.deployment_status.id;


--
-- Name: docker_artifact_store; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.docker_artifact_store (
    id character varying(250) NOT NULL,
    plugin_id character varying(250) NOT NULL,
    registry_url character varying(250) NOT NULL,
    registry_type character varying(250) NOT NULL,
    aws_accesskey_id character varying(250),
    aws_secret_accesskey character varying(250),
    aws_region character varying(250),
    username character varying(250),
    password character varying(250),
    is_default boolean NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.docker_artifact_store OWNER TO postgres;

--
-- Name: env_level_app_metrics; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.env_level_app_metrics (
    id integer NOT NULL,
    app_id integer NOT NULL,
    env_id integer NOT NULL,
    app_metrics boolean,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    infra_metrics boolean DEFAULT true
);


ALTER TABLE public.env_level_app_metrics OWNER TO postgres;

--
-- Name: env_level_app_metrics_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.env_level_app_metrics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.env_level_app_metrics_id_seq OWNER TO postgres;

--
-- Name: env_level_app_metrics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.env_level_app_metrics_id_seq OWNED BY public.env_level_app_metrics.id;


--
-- Name: environment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.environment (
    id integer NOT NULL,
    environment_name character varying(250) NOT NULL,
    cluster_id integer NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    "default" boolean DEFAULT false NOT NULL,
    namespace character varying(250),
    grafana_datasource_id integer
);


ALTER TABLE public.environment OWNER TO postgres;

--
-- Name: environment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.environment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.environment_id_seq OWNER TO postgres;

--
-- Name: environment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.environment_id_seq OWNED BY public.environment.id;


--
-- Name: event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.event (
    id integer NOT NULL,
    event_type character varying(100) NOT NULL,
    description character varying(250)
);


ALTER TABLE public.event OWNER TO postgres;

--
-- Name: event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.event_id_seq OWNER TO postgres;

--
-- Name: event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.event_id_seq OWNED BY public.event.id;


--
-- Name: events; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.events (
    id integer NOT NULL,
    namespace character varying(250),
    kind character varying(250),
    component character varying(250),
    host character varying(250),
    reason character varying(250),
    status character varying(250),
    name character varying(250),
    message character varying(250),
    resource_revision character varying(250),
    creation_time_stamp timestamp with time zone,
    uid character varying(250),
    pipeline_name character varying(250),
    release_version character varying(250),
    created_on timestamp with time zone NOT NULL,
    created_by character varying(250) NOT NULL
);


ALTER TABLE public.events OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.events_id_seq OWNER TO postgres;

--
-- Name: events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.events_id_seq OWNED BY public.events.id;


--
-- Name: external_ci_pipeline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.external_ci_pipeline (
    id integer NOT NULL,
    ci_pipeline_id integer NOT NULL,
    access_token character varying(256) NOT NULL,
    active boolean,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer
);


ALTER TABLE public.external_ci_pipeline OWNER TO postgres;

--
-- Name: external_ci_pipeline_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.external_ci_pipeline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.external_ci_pipeline_id_seq OWNER TO postgres;

--
-- Name: external_ci_pipeline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.external_ci_pipeline_id_seq OWNED BY public.external_ci_pipeline.id;


--
-- Name: git_material; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.git_material (
    id integer NOT NULL,
    app_id integer,
    git_provider_id integer,
    active boolean NOT NULL,
    name character varying(250),
    url character varying(250),
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    checkout_path character varying(250)
);


ALTER TABLE public.git_material OWNER TO postgres;

--
-- Name: git_material_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.git_material_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.git_material_id_seq OWNER TO postgres;

--
-- Name: git_material_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.git_material_id_seq OWNED BY public.git_material.id;


--
-- Name: git_provider; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.git_provider (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    url character varying(250) NOT NULL,
    user_name character varying(25),
    password character varying(250),
    ssh_key character varying(250),
    access_token character varying(250),
    auth_mode character varying(250),
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.git_provider OWNER TO postgres;

--
-- Name: git_provider_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.git_provider_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.git_provider_id_seq OWNER TO postgres;

--
-- Name: git_provider_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.git_provider_id_seq OWNED BY public.git_provider.id;


--
-- Name: git_web_hook; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.git_web_hook (
    id integer NOT NULL,
    ci_material_id integer NOT NULL,
    git_material_id integer NOT NULL,
    type character varying(250),
    value character varying(250),
    active boolean,
    last_seen_hash character varying(250),
    created_on timestamp with time zone
);


ALTER TABLE public.git_web_hook OWNER TO postgres;

--
-- Name: git_web_hook_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.git_web_hook_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.git_web_hook_id_seq OWNER TO postgres;

--
-- Name: git_web_hook_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.git_web_hook_id_seq OWNED BY public.git_web_hook.id;


--
-- Name: helm_values; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.helm_values (
    app_name character varying(250) NOT NULL,
    environment character varying(250) NOT NULL,
    values_yaml text NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.helm_values OWNER TO postgres;

--
-- Name: id_seq_pconfig; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.id_seq_pconfig
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.id_seq_pconfig OWNER TO postgres;

--
-- Name: image_scan_deploy_info_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.image_scan_deploy_info_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_scan_deploy_info_id_seq OWNER TO postgres;

--
-- Name: image_scan_deploy_info; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_scan_deploy_info (
    id integer DEFAULT nextval('public.image_scan_deploy_info_id_seq'::regclass) NOT NULL,
    image_scan_execution_history_id integer[],
    scan_object_meta_id integer,
    object_type character varying(255),
    cluster_id integer,
    env_id integer,
    created_on timestamp without time zone,
    created_by integer,
    updated_on timestamp without time zone,
    updated_by integer
);


ALTER TABLE public.image_scan_deploy_info OWNER TO postgres;

--
-- Name: image_scan_execution_history_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.image_scan_execution_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_scan_execution_history_id_seq OWNER TO postgres;

--
-- Name: image_scan_execution_history; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_scan_execution_history (
    id integer DEFAULT nextval('public.image_scan_execution_history_id_seq'::regclass) NOT NULL,
    image character varying(255),
    execution_time timestamp with time zone,
    executed_by integer,
    image_hash character varying(255)
);


ALTER TABLE public.image_scan_execution_history OWNER TO postgres;

--
-- Name: image_scan_execution_result_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.image_scan_execution_result_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_scan_execution_result_id_seq OWNER TO postgres;

--
-- Name: image_scan_execution_result; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_scan_execution_result (
    id integer DEFAULT nextval('public.image_scan_execution_result_id_seq'::regclass) NOT NULL,
    image_scan_execution_history_id integer NOT NULL,
    cve_store_name character varying(255) NOT NULL
);


ALTER TABLE public.image_scan_execution_result OWNER TO postgres;

--
-- Name: image_scan_object_meta_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.image_scan_object_meta_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.image_scan_object_meta_id_seq OWNER TO postgres;

--
-- Name: image_scan_object_meta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.image_scan_object_meta (
    id integer DEFAULT nextval('public.image_scan_object_meta_id_seq'::regclass) NOT NULL,
    name character varying(255),
    type character varying(255),
    image character varying(255),
    active boolean
);


ALTER TABLE public.image_scan_object_meta OWNER TO postgres;

--
-- Name: installed_app_versions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.installed_app_versions (
    id integer NOT NULL,
    installed_app_id integer,
    app_store_application_version_id integer,
    values_yaml json NOT NULL,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    values_yaml_raw text,
    active boolean DEFAULT true,
    reference_value_id integer,
    reference_value_kind character varying(250)
);


ALTER TABLE public.installed_app_versions OWNER TO postgres;

--
-- Name: installed_app_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.installed_app_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.installed_app_versions_id_seq OWNER TO postgres;

--
-- Name: installed_app_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.installed_app_versions_id_seq OWNED BY public.installed_app_versions.id;


--
-- Name: installed_apps; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.installed_apps (
    id integer NOT NULL,
    app_id integer,
    environment_id integer,
    created_by integer,
    updated_by integer,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    active boolean DEFAULT true,
    status integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.installed_apps OWNER TO postgres;

--
-- Name: installed_apps_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.installed_apps_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.installed_apps_id_seq OWNER TO postgres;

--
-- Name: installed_apps_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.installed_apps_id_seq OWNED BY public.installed_apps.id;


--
-- Name: job_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_event (
    id integer NOT NULL,
    event_trigger_time character varying(100) NOT NULL,
    name character varying(150) NOT NULL,
    status character varying(150) NOT NULL,
    message character varying(250),
    created_on timestamp with time zone,
    updated_on timestamp with time zone
);


ALTER TABLE public.job_event OWNER TO postgres;

--
-- Name: job_event_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.job_event_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.job_event_id_seq OWNER TO postgres;

--
-- Name: job_event_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.job_event_id_seq OWNED BY public.job_event.id;


--
-- Name: notification_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_settings (
    id integer NOT NULL,
    app_id integer,
    env_id integer,
    pipeline_id integer,
    pipeline_type character varying(50) NOT NULL,
    event_type_id integer NOT NULL,
    config json NOT NULL,
    view_id integer NOT NULL,
    team_id integer
);


ALTER TABLE public.notification_settings OWNER TO postgres;

--
-- Name: notification_settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_settings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_settings_id_seq OWNER TO postgres;

--
-- Name: notification_settings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_settings_id_seq OWNED BY public.notification_settings.id;


--
-- Name: notification_settings_view; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_settings_view (
    id integer NOT NULL,
    config json NOT NULL,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer
);


ALTER TABLE public.notification_settings_view OWNER TO postgres;

--
-- Name: notification_settings_view_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_settings_view_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_settings_view_id_seq OWNER TO postgres;

--
-- Name: notification_settings_view_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_settings_view_id_seq OWNED BY public.notification_settings_view.id;


--
-- Name: notification_templates; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notification_templates (
    id integer NOT NULL,
    channel_type character varying(100) NOT NULL,
    node_type character varying(50) NOT NULL,
    event_type_id integer NOT NULL,
    template_name character varying(250) NOT NULL,
    template_payload text NOT NULL
);


ALTER TABLE public.notification_templates OWNER TO postgres;

--
-- Name: notification_templates_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notification_templates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notification_templates_id_seq OWNER TO postgres;

--
-- Name: notification_templates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notification_templates_id_seq OWNED BY public.notification_templates.id;


--
-- Name: notifier_event_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifier_event_log (
    id integer NOT NULL,
    destination character varying(250) NOT NULL,
    source_id integer,
    pipeline_type character varying(100) NOT NULL,
    event_type_id integer NOT NULL,
    correlation_id character varying(250) NOT NULL,
    payload text,
    is_notification_sent boolean NOT NULL,
    event_time timestamp with time zone NOT NULL,
    created_at timestamp with time zone NOT NULL
);


ALTER TABLE public.notifier_event_log OWNER TO postgres;

--
-- Name: notifier_event_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifier_event_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.notifier_event_log_id_seq OWNER TO postgres;

--
-- Name: notifier_event_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifier_event_log_id_seq OWNED BY public.notifier_event_log.id;


--
-- Name: pipeline; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pipeline (
    id integer NOT NULL,
    app_id integer,
    ci_pipeline_id integer,
    trigger_type character varying(250) NOT NULL,
    environment_id integer,
    deployment_template character varying(250),
    pipeline_name character varying(250) NOT NULL,
    deleted boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    pipeline_override text DEFAULT '{}'::text,
    pre_stage_config_yaml text,
    post_stage_config_yaml text,
    pre_trigger_type character varying(250),
    post_trigger_type character varying(250),
    pre_stage_config_map_secret_names text,
    post_stage_config_map_secret_names text,
    run_pre_stage_in_env boolean DEFAULT false,
    run_post_stage_in_env boolean DEFAULT false
);


ALTER TABLE public.pipeline OWNER TO postgres;

--
-- Name: pipeline_config_override; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pipeline_config_override (
    id integer NOT NULL,
    request_identifier character varying(250) NOT NULL,
    env_config_override_id integer,
    pipeline_override_yaml text NOT NULL,
    merged_values_yaml text NOT NULL,
    status character varying(50) NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    git_hash character varying(250),
    ci_artifact_id integer,
    pipeline_id integer,
    pipeline_release_counter integer,
    cd_workflow_id integer,
    deployment_type integer DEFAULT 0
);


ALTER TABLE public.pipeline_config_override OWNER TO postgres;

--
-- Name: pipeline_config_override_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pipeline_config_override_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipeline_config_override_id_seq OWNER TO postgres;

--
-- Name: pipeline_config_override_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pipeline_config_override_id_seq OWNED BY public.pipeline_config_override.id;


--
-- Name: pipeline_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pipeline_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipeline_id_seq OWNER TO postgres;

--
-- Name: pipeline_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pipeline_id_seq OWNED BY public.pipeline.id;


--
-- Name: pipeline_strategy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pipeline_strategy (
    id integer NOT NULL,
    strategy character varying(250) NOT NULL,
    config text,
    created_by integer,
    updated_by integer,
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    deleted boolean,
    "default" boolean NOT NULL,
    pipeline_id integer NOT NULL
);


ALTER TABLE public.pipeline_strategy OWNER TO postgres;

--
-- Name: pipeline_strategy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pipeline_strategy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pipeline_strategy_id_seq OWNER TO postgres;

--
-- Name: pipeline_strategy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pipeline_strategy_id_seq OWNED BY public.pipeline_strategy.id;


--
-- Name: project_management_tool_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.project_management_tool_config (
    id integer NOT NULL,
    user_name character varying(250) NOT NULL,
    account_url character varying(250) NOT NULL,
    auth_token character varying(250) NOT NULL,
    commit_message_regex character varying(250) NOT NULL,
    final_issue_status character varying(250) NOT NULL,
    pipeline_stage character varying(250) NOT NULL,
    pipeline_id integer NOT NULL,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.project_management_tool_config OWNER TO postgres;

--
-- Name: project_management_tool_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.project_management_tool_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.project_management_tool_config_id_seq OWNER TO postgres;

--
-- Name: project_management_tool_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.project_management_tool_config_id_seq OWNED BY public.project_management_tool_config.id;


--
-- Name: role_group; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_group (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    casbin_name character varying(100),
    description text,
    created_by integer,
    updated_by integer,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.role_group OWNER TO postgres;

--
-- Name: role_group_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_group_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_group_id_seq OWNER TO postgres;

--
-- Name: role_group_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_group_id_seq OWNED BY public.role_group.id;


--
-- Name: role_group_role_mapping; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.role_group_role_mapping (
    id integer NOT NULL,
    role_group_id integer NOT NULL,
    role_id integer NOT NULL,
    created_by integer,
    updated_by integer,
    created_on timestamp with time zone NOT NULL,
    updated_on timestamp with time zone NOT NULL
);


ALTER TABLE public.role_group_role_mapping OWNER TO postgres;

--
-- Name: role_group_role_mapping_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.role_group_role_mapping_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.role_group_role_mapping_id_seq OWNER TO postgres;

--
-- Name: role_group_role_mapping_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.role_group_role_mapping_id_seq OWNED BY public.role_group_role_mapping.id;


--
-- Name: roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.roles_id_seq OWNER TO postgres;

--
-- Name: roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.roles (
    id integer DEFAULT nextval('public.roles_id_seq'::regclass) NOT NULL,
    role character varying(100) NOT NULL,
    team character varying(100),
    environment text,
    entity_name text,
    action character varying(100),
    created_by integer,
    created_on timestamp without time zone,
    updated_by integer,
    updated_on timestamp without time zone,
    entity character varying(100)
);


ALTER TABLE public.roles OWNER TO postgres;

--
-- Name: ses_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ses_config (
    id integer NOT NULL,
    region character varying(50) NOT NULL,
    access_key character varying(250) NOT NULL,
    secret_access_key character varying(250) NOT NULL,
    session_token character varying(250),
    from_email character varying(250) NOT NULL,
    config_name character varying(250),
    description character varying(500),
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    owner_id integer,
    "default" boolean
);


ALTER TABLE public.ses_config OWNER TO postgres;

--
-- Name: ses_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ses_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ses_config_id_seq OWNER TO postgres;

--
-- Name: ses_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ses_config_id_seq OWNED BY public.ses_config.id;


--
-- Name: slack_config; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slack_config (
    id integer NOT NULL,
    web_hook_url character varying(250) NOT NULL,
    config_name character varying(250) NOT NULL,
    description character varying(500),
    created_on timestamp with time zone,
    updated_on timestamp with time zone,
    created_by integer,
    updated_by integer,
    owner_id integer,
    team_id integer
);


ALTER TABLE public.slack_config OWNER TO postgres;

--
-- Name: slack_config_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.slack_config_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.slack_config_id_seq OWNER TO postgres;

--
-- Name: slack_config_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.slack_config_id_seq OWNED BY public.slack_config.id;


--
-- Name: team; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.team (
    id integer NOT NULL,
    name character varying(250) NOT NULL,
    active boolean NOT NULL,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL
);


ALTER TABLE public.team OWNER TO postgres;

--
-- Name: team_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.team_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.team_id_seq OWNER TO postgres;

--
-- Name: team_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.team_id_seq OWNED BY public.team.id;


--
-- Name: user_roles_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.user_roles_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_roles_id_seq OWNER TO postgres;

--
-- Name: user_roles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.user_roles (
    id integer DEFAULT nextval('public.user_roles_id_seq'::regclass) NOT NULL,
    user_id integer NOT NULL,
    role_id integer NOT NULL,
    created_by integer,
    created_on timestamp without time zone,
    updated_by integer,
    updated_on timestamp without time zone
);


ALTER TABLE public.user_roles OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.users_id_seq OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer DEFAULT nextval('public.users_id_seq'::regclass) NOT NULL,
    fname text,
    lname text,
    password text,
    access_token text,
    created_on timestamp without time zone,
    email_id character varying(100) NOT NULL,
    created_by integer,
    updated_by integer,
    updated_on timestamp without time zone,
    active boolean DEFAULT true NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: app id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app ALTER COLUMN id SET DEFAULT nextval('public.app_id_seq'::regclass);


--
-- Name: app_env_linkouts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_env_linkouts ALTER COLUMN id SET DEFAULT nextval('public.app_env_linkouts_id_seq'::regclass);


--
-- Name: app_level_metrics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_level_metrics ALTER COLUMN id SET DEFAULT nextval('public.app_level_metrics_id_seq'::regclass);


--
-- Name: app_store id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store ALTER COLUMN id SET DEFAULT nextval('public.app_store_id_seq'::regclass);


--
-- Name: app_store_application_version id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store_application_version ALTER COLUMN id SET DEFAULT nextval('public.app_store_application_version_id_seq'::regclass);


--
-- Name: app_store_version_values id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store_version_values ALTER COLUMN id SET DEFAULT nextval('public.app_store_version_values_id_seq'::regclass);


--
-- Name: app_workflow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_workflow ALTER COLUMN id SET DEFAULT nextval('public.app_workflow_id_seq'::regclass);


--
-- Name: cd_workflow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow ALTER COLUMN id SET DEFAULT nextval('public.cd_workflow_id_seq'::regclass);


--
-- Name: cd_workflow_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow_config ALTER COLUMN id SET DEFAULT nextval('public.cd_workflow_config_id_seq'::regclass);


--
-- Name: cd_workflow_runner id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow_runner ALTER COLUMN id SET DEFAULT nextval('public.cd_workflow_runner_id_seq'::regclass);


--
-- Name: chart_env_config_override id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_env_config_override ALTER COLUMN id SET DEFAULT nextval('public.chart_env_config_override_id_seq'::regclass);


--
-- Name: chart_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group ALTER COLUMN id SET DEFAULT nextval('public.chart_group_id_seq'::regclass);


--
-- Name: chart_group_deployment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_deployment ALTER COLUMN id SET DEFAULT nextval('public.chart_group_deployment_id_seq'::regclass);


--
-- Name: chart_group_entry id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_entry ALTER COLUMN id SET DEFAULT nextval('public.chart_group_entry_id_seq'::regclass);


--
-- Name: chart_repo id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_repo ALTER COLUMN id SET DEFAULT nextval('public.chart_repo_id_seq'::regclass);


--
-- Name: charts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charts ALTER COLUMN id SET DEFAULT nextval('public.charts_id_seq'::regclass);


--
-- Name: ci_artifact id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_artifact ALTER COLUMN id SET DEFAULT nextval('public.ci_artifact_id_seq'::regclass);


--
-- Name: ci_pipeline id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline ALTER COLUMN id SET DEFAULT nextval('public.ci_pipeline_id_seq'::regclass);


--
-- Name: ci_pipeline_material id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_material ALTER COLUMN id SET DEFAULT nextval('public.ci_pipeline_material_id_seq'::regclass);


--
-- Name: ci_pipeline_scripts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_scripts ALTER COLUMN id SET DEFAULT nextval('public.ci_pipeline_scripts_id_seq'::regclass);


--
-- Name: ci_template id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_template ALTER COLUMN id SET DEFAULT nextval('public.ci_template_id_seq'::regclass);


--
-- Name: ci_workflow id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow ALTER COLUMN id SET DEFAULT nextval('public.ci_workflow_id_seq'::regclass);


--
-- Name: ci_workflow_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow_config ALTER COLUMN id SET DEFAULT nextval('public.ci_workflow_config_id_seq'::regclass);


--
-- Name: cluster id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster ALTER COLUMN id SET DEFAULT nextval('public.cluster_id_seq'::regclass);


--
-- Name: cluster_accounts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_accounts ALTER COLUMN id SET DEFAULT nextval('public.cluster_accounts_id_seq'::regclass);


--
-- Name: cluster_helm_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_helm_config ALTER COLUMN id SET DEFAULT nextval('public.cluster_helm_config_id_seq'::regclass);


--
-- Name: db_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_config ALTER COLUMN id SET DEFAULT nextval('public.db_config_id_seq'::regclass);


--
-- Name: db_migration_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_migration_config ALTER COLUMN id SET DEFAULT nextval('public.db_migration_config_id_seq'::regclass);


--
-- Name: deployment_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group ALTER COLUMN id SET DEFAULT nextval('public.deployment_group_id_seq'::regclass);


--
-- Name: deployment_group_app id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group_app ALTER COLUMN id SET DEFAULT nextval('public.deployment_group_app_id_seq'::regclass);


--
-- Name: deployment_status id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_status ALTER COLUMN id SET DEFAULT nextval('public.deployment_status_id_seq'::regclass);


--
-- Name: env_level_app_metrics id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.env_level_app_metrics ALTER COLUMN id SET DEFAULT nextval('public.env_level_app_metrics_id_seq'::regclass);


--
-- Name: environment id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.environment ALTER COLUMN id SET DEFAULT nextval('public.environment_id_seq'::regclass);


--
-- Name: event id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event ALTER COLUMN id SET DEFAULT nextval('public.event_id_seq'::regclass);


--
-- Name: events id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events ALTER COLUMN id SET DEFAULT nextval('public.events_id_seq'::regclass);


--
-- Name: external_ci_pipeline id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_ci_pipeline ALTER COLUMN id SET DEFAULT nextval('public.external_ci_pipeline_id_seq'::regclass);


--
-- Name: git_material id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_material ALTER COLUMN id SET DEFAULT nextval('public.git_material_id_seq'::regclass);


--
-- Name: git_provider id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_provider ALTER COLUMN id SET DEFAULT nextval('public.git_provider_id_seq'::regclass);


--
-- Name: git_web_hook id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_web_hook ALTER COLUMN id SET DEFAULT nextval('public.git_web_hook_id_seq'::regclass);


--
-- Name: installed_app_versions id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_app_versions ALTER COLUMN id SET DEFAULT nextval('public.installed_app_versions_id_seq'::regclass);


--
-- Name: installed_apps id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_apps ALTER COLUMN id SET DEFAULT nextval('public.installed_apps_id_seq'::regclass);


--
-- Name: job_event id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_event ALTER COLUMN id SET DEFAULT nextval('public.job_event_id_seq'::regclass);


--
-- Name: notification_settings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings ALTER COLUMN id SET DEFAULT nextval('public.notification_settings_id_seq'::regclass);


--
-- Name: notification_settings_view id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings_view ALTER COLUMN id SET DEFAULT nextval('public.notification_settings_view_id_seq'::regclass);


--
-- Name: notification_templates id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_templates ALTER COLUMN id SET DEFAULT nextval('public.notification_templates_id_seq'::regclass);


--
-- Name: notifier_event_log id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifier_event_log ALTER COLUMN id SET DEFAULT nextval('public.notifier_event_log_id_seq'::regclass);


--
-- Name: pipeline id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline ALTER COLUMN id SET DEFAULT nextval('public.pipeline_id_seq'::regclass);


--
-- Name: pipeline_config_override id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_config_override ALTER COLUMN id SET DEFAULT nextval('public.pipeline_config_override_id_seq'::regclass);


--
-- Name: pipeline_strategy id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_strategy ALTER COLUMN id SET DEFAULT nextval('public.pipeline_strategy_id_seq'::regclass);


--
-- Name: project_management_tool_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_management_tool_config ALTER COLUMN id SET DEFAULT nextval('public.project_management_tool_config_id_seq'::regclass);


--
-- Name: role_group id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_group ALTER COLUMN id SET DEFAULT nextval('public.role_group_id_seq'::regclass);


--
-- Name: role_group_role_mapping id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_group_role_mapping ALTER COLUMN id SET DEFAULT nextval('public.role_group_role_mapping_id_seq'::regclass);


--
-- Name: ses_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ses_config ALTER COLUMN id SET DEFAULT nextval('public.ses_config_id_seq'::regclass);


--
-- Name: slack_config id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slack_config ALTER COLUMN id SET DEFAULT nextval('public.slack_config_id_seq'::regclass);


--
-- Name: team id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team ALTER COLUMN id SET DEFAULT nextval('public.team_id_seq'::regclass);



--
-- Name: app_env_linkouts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_env_linkouts_id_seq', 1, false);


--
-- Name: app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_id_seq', 1, false);


--
-- Name: app_level_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_level_metrics_id_seq', 1, false);


--
-- Name: app_store_application_version_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_store_application_version_id_seq', 1, false);


--
-- Name: app_store_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_store_id_seq', 1, false);


--
-- Name: app_store_version_values_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_store_version_values_id_seq', 1, false);


--
-- Name: app_workflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_workflow_id_seq', 1, false);


--
-- Name: app_workflow_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.app_workflow_mapping_id_seq', 1, false);


--
-- Name: casbin_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.casbin_id_seq', 1, false);


--
-- Name: casbin_role_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.casbin_role_id_seq', 1, false);


--
-- Name: cd_workflow_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cd_workflow_config_id_seq', 1, false);


--
-- Name: cd_workflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cd_workflow_id_seq', 1, false);


--
-- Name: cd_workflow_runner_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cd_workflow_runner_id_seq', 1, false);


--
-- Name: chart_env_config_override_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chart_env_config_override_id_seq', 1, false);


--
-- Name: chart_group_deployment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chart_group_deployment_id_seq', 1, false);


--
-- Name: chart_group_entry_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chart_group_entry_id_seq', 1, false);


--
-- Name: chart_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chart_group_id_seq', 1, false);


--
-- Name: chart_repo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chart_repo_id_seq', 12, true);


--
-- Name: charts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.charts_id_seq', 1, false);


--
-- Name: ci_artifact_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_artifact_id_seq', 1, false);


--
-- Name: ci_pipeline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_pipeline_id_seq', 1, false);


--
-- Name: ci_pipeline_material_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_pipeline_material_id_seq', 1, false);


--
-- Name: ci_pipeline_scripts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_pipeline_scripts_id_seq', 1, false);


--
-- Name: ci_template_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_template_id_seq', 1, false);


--
-- Name: ci_workflow_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_workflow_config_id_seq', 1, false);


--
-- Name: ci_workflow_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ci_workflow_id_seq', 1, false);


--
-- Name: cluster_accounts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cluster_accounts_id_seq', 1, false);


--
-- Name: cluster_helm_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cluster_helm_config_id_seq', 1, false);


--
-- Name: cluster_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cluster_id_seq', 1, true);


--
-- Name: cluster_installed_apps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cluster_installed_apps_id_seq', 1, false);


--
-- Name: cve_policy_control_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.cve_policy_control_id_seq', 3, true);


--
-- Name: db_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.db_config_id_seq', 1, false);


--
-- Name: db_migration_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.db_migration_config_id_seq', 1, false);


--
-- Name: deployment_group_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deployment_group_app_id_seq', 1, false);


--
-- Name: deployment_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deployment_group_id_seq', 1, false);


--
-- Name: deployment_status_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.deployment_status_id_seq', 1, false);


--
-- Name: env_level_app_metrics_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.env_level_app_metrics_id_seq', 1, false);


--
-- Name: environment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.environment_id_seq', 1, true);


--
-- Name: event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.event_id_seq', 3, true);


--
-- Name: events_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.events_id_seq', 1, false);


--
-- Name: external_ci_pipeline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.external_ci_pipeline_id_seq', 1, false);


--
-- Name: git_material_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.git_material_id_seq', 1, false);


--
-- Name: git_provider_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.git_provider_id_seq', 1, true);


--
-- Name: git_web_hook_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.git_web_hook_id_seq', 1, false);


--
-- Name: id_seq_chart_ref; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_seq_chart_ref', 10, true);


--
-- Name: id_seq_config_map_app_level; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_seq_config_map_app_level', 1, false);


--
-- Name: id_seq_config_map_env_level; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_seq_config_map_env_level', 1, false);


--
-- Name: id_seq_config_map_pipeline_level; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_seq_config_map_pipeline_level', 1, false);


--
-- Name: id_seq_pconfig; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.id_seq_pconfig', 1, false);


--
-- Name: image_scan_deploy_info_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.image_scan_deploy_info_id_seq', 1, false);


--
-- Name: image_scan_execution_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.image_scan_execution_history_id_seq', 1, false);


--
-- Name: image_scan_execution_result_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.image_scan_execution_result_id_seq', 1, false);


--
-- Name: image_scan_object_meta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.image_scan_object_meta_id_seq', 1, false);


--
-- Name: installed_app_versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.installed_app_versions_id_seq', 1, false);


--
-- Name: installed_apps_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.installed_apps_id_seq', 1, false);


--
-- Name: job_event_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.job_event_id_seq', 1, false);


--
-- Name: notification_settings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_settings_id_seq', 1, false);


--
-- Name: notification_settings_view_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_settings_view_id_seq', 1, false);


--
-- Name: notification_templates_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notification_templates_id_seq', 12, true);


--
-- Name: notifier_event_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifier_event_log_id_seq', 1, false);


--
-- Name: pipeline_config_override_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pipeline_config_override_id_seq', 1, false);


--
-- Name: pipeline_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pipeline_id_seq', 1, false);


--
-- Name: pipeline_strategy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pipeline_strategy_id_seq', 1, false);


--
-- Name: project_management_tool_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.project_management_tool_config_id_seq', 1, false);


--
-- Name: role_group_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_group_id_seq', 1, false);


--
-- Name: role_group_role_mapping_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.role_group_role_mapping_id_seq', 1, false);


--
-- Name: roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.roles_id_seq', 1, true);


--
-- Name: ses_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ses_config_id_seq', 1, false);


--
-- Name: slack_config_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.slack_config_id_seq', 1, false);


--
-- Name: team_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.team_id_seq', 1, true);


--
-- Name: user_roles_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.user_roles_id_seq', 1, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: app app_app_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT app_app_name_key UNIQUE (app_name);


--
-- Name: app_env_linkouts app_env_linkouts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_env_linkouts
    ADD CONSTRAINT app_env_linkouts_pkey PRIMARY KEY (id);


--
-- Name: app_level_metrics app_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_level_metrics
    ADD CONSTRAINT app_metrics_pkey PRIMARY KEY (id);


--
-- Name: app app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT app_pkey PRIMARY KEY (id);


--
-- Name: app_store_application_version app_store_application_version_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store_application_version
    ADD CONSTRAINT app_store_application_version_pkey PRIMARY KEY (id);


--
-- Name: app_store app_store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store
    ADD CONSTRAINT app_store_pkey PRIMARY KEY (id);


--
-- Name: app_store app_store_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store
    ADD CONSTRAINT app_store_unique UNIQUE (name, chart_repo_id);


--
-- Name: app_store_version_values app_store_version_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store_version_values
    ADD CONSTRAINT app_store_version_values_pkey PRIMARY KEY (id);


--
-- Name: app_workflow_mapping app_workflow_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_workflow_mapping
    ADD CONSTRAINT app_workflow_mapping_pkey PRIMARY KEY (id);


--
-- Name: app_workflow app_workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_workflow
    ADD CONSTRAINT app_workflow_pkey PRIMARY KEY (id);


--
-- Name: cd_workflow_config cd_workflow_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow_config
    ADD CONSTRAINT cd_workflow_config_pkey PRIMARY KEY (id);


--
-- Name: cd_workflow cd_workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow
    ADD CONSTRAINT cd_workflow_pkey PRIMARY KEY (id);


--
-- Name: cd_workflow_runner cd_workflow_runner_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow_runner
    ADD CONSTRAINT cd_workflow_runner_pkey PRIMARY KEY (id);


--
-- Name: chart_env_config_override chart_env_config_override_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_env_config_override
    ADD CONSTRAINT chart_env_config_override_pkey PRIMARY KEY (id);


--
-- Name: chart_group_deployment chart_group_deployment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_deployment
    ADD CONSTRAINT chart_group_deployment_pkey PRIMARY KEY (id);


--
-- Name: chart_group_entry chart_group_entry_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_entry
    ADD CONSTRAINT chart_group_entry_pkey PRIMARY KEY (id);


--
-- Name: chart_group chart_group_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group
    ADD CONSTRAINT chart_group_name_key UNIQUE (name);


--
-- Name: chart_group chart_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group
    ADD CONSTRAINT chart_group_pkey PRIMARY KEY (id);


--
-- Name: chart_repo chart_repo_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_repo
    ADD CONSTRAINT chart_repo_pkey PRIMARY KEY (id);


--
-- Name: charts charts_chart_name_chart_version_chart_repo_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charts
    ADD CONSTRAINT charts_chart_name_chart_version_chart_repo_key UNIQUE (chart_name, chart_version, chart_repo);


--
-- Name: charts charts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charts
    ADD CONSTRAINT charts_pkey PRIMARY KEY (id);


--
-- Name: ci_artifact ci_artifact_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_artifact
    ADD CONSTRAINT ci_artifact_pkey PRIMARY KEY (id);


--
-- Name: ci_pipeline_material ci_pipeline_material_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_material
    ADD CONSTRAINT ci_pipeline_material_pkey PRIMARY KEY (id);


--
-- Name: ci_pipeline ci_pipeline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline
    ADD CONSTRAINT ci_pipeline_pkey PRIMARY KEY (id);


--
-- Name: ci_pipeline_scripts ci_pipeline_scripts_name_ci_pipeline_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_scripts
    ADD CONSTRAINT ci_pipeline_scripts_name_ci_pipeline_id_key UNIQUE (name, ci_pipeline_id);


--
-- Name: ci_pipeline_scripts ci_pipeline_scripts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_scripts
    ADD CONSTRAINT ci_pipeline_scripts_pkey PRIMARY KEY (id);


--
-- Name: ci_template ci_template_app_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_template
    ADD CONSTRAINT ci_template_app_id_key UNIQUE (app_id);


--
-- Name: ci_template ci_template_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_template
    ADD CONSTRAINT ci_template_pkey PRIMARY KEY (id);


--
-- Name: ci_workflow_config ci_workflow_config_ci_pipeline_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow_config
    ADD CONSTRAINT ci_workflow_config_ci_pipeline_id_key UNIQUE (ci_pipeline_id);


--
-- Name: ci_workflow_config ci_workflow_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow_config
    ADD CONSTRAINT ci_workflow_config_pkey PRIMARY KEY (id);


--
-- Name: ci_workflow ci_workflow_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow
    ADD CONSTRAINT ci_workflow_pkey PRIMARY KEY (id);


--
-- Name: cluster_accounts cluster_accounts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_accounts
    ADD CONSTRAINT cluster_accounts_pkey PRIMARY KEY (id);


--
-- Name: cluster_helm_config cluster_helm_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_helm_config
    ADD CONSTRAINT cluster_helm_config_pkey PRIMARY KEY (id);


--
-- Name: cluster_installed_apps cluster_installed_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_installed_apps
    ADD CONSTRAINT cluster_installed_apps_pkey PRIMARY KEY (id);


--
-- Name: cluster cluster_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster
    ADD CONSTRAINT cluster_pkey PRIMARY KEY (id);


--
-- Name: cve_policy_control cve_policy_control_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve_policy_control
    ADD CONSTRAINT cve_policy_control_pkey PRIMARY KEY (id);


--
-- Name: cve_store cve_store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve_store
    ADD CONSTRAINT cve_store_pkey PRIMARY KEY (name);


--
-- Name: db_config db_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_config
    ADD CONSTRAINT db_config_pkey PRIMARY KEY (id);


--
-- Name: db_migration_config db_migration_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_migration_config
    ADD CONSTRAINT db_migration_config_pkey PRIMARY KEY (id);


--
-- Name: deployment_group_app deployment_group_app_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group_app
    ADD CONSTRAINT deployment_group_app_pkey PRIMARY KEY (id);


--
-- Name: deployment_group deployment_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group
    ADD CONSTRAINT deployment_group_pkey PRIMARY KEY (id);


--
-- Name: docker_artifact_store docker_artifact_store_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.docker_artifact_store
    ADD CONSTRAINT docker_artifact_store_pkey PRIMARY KEY (id);


--
-- Name: deployment_status ds_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_status
    ADD CONSTRAINT ds_pkey PRIMARY KEY (id);


--
-- Name: env_level_app_metrics env_metrics_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.env_level_app_metrics
    ADD CONSTRAINT env_metrics_pkey PRIMARY KEY (id);


--
-- Name: environment environment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.environment
    ADD CONSTRAINT environment_pkey PRIMARY KEY (id);


--
-- Name: event event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT event_pkey PRIMARY KEY (id);


--
-- Name: events events_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.events
    ADD CONSTRAINT events_pkey PRIMARY KEY (id);


--
-- Name: external_ci_pipeline external_ci_pipeline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_ci_pipeline
    ADD CONSTRAINT external_ci_pipeline_pkey PRIMARY KEY (id);


--
-- Name: git_material git_material_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_material
    ADD CONSTRAINT git_material_pkey PRIMARY KEY (id);


--
-- Name: git_provider git_provider_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_provider
    ADD CONSTRAINT git_provider_name_key UNIQUE (name);


--
-- Name: git_provider git_provider_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_provider
    ADD CONSTRAINT git_provider_pkey PRIMARY KEY (id);


--
-- Name: git_provider git_provider_url_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_provider
    ADD CONSTRAINT git_provider_url_key UNIQUE (url);


--
-- Name: git_web_hook git_web_hook_ci_material_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_web_hook
    ADD CONSTRAINT git_web_hook_ci_material_id_key UNIQUE (ci_material_id);


--
-- Name: git_web_hook git_web_hook_git_material_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_web_hook
    ADD CONSTRAINT git_web_hook_git_material_id_key UNIQUE (git_material_id);


--
-- Name: git_web_hook git_web_hook_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_web_hook
    ADD CONSTRAINT git_web_hook_pkey PRIMARY KEY (id);


--
-- Name: helm_values helm_values_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.helm_values
    ADD CONSTRAINT helm_values_pkey PRIMARY KEY (app_name, environment);


--
-- Name: image_scan_deploy_info image_scan_deploy_info_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_deploy_info
    ADD CONSTRAINT image_scan_deploy_info_pkey PRIMARY KEY (id);


--
-- Name: image_scan_execution_history image_scan_execution_history_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_execution_history
    ADD CONSTRAINT image_scan_execution_history_pkey PRIMARY KEY (id);


--
-- Name: image_scan_execution_result image_scan_execution_result_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_execution_result
    ADD CONSTRAINT image_scan_execution_result_pkey PRIMARY KEY (id);


--
-- Name: image_scan_object_meta image_scan_object_meta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_object_meta
    ADD CONSTRAINT image_scan_object_meta_pkey PRIMARY KEY (id);


--
-- Name: installed_app_versions installed_app_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_app_versions
    ADD CONSTRAINT installed_app_versions_pkey PRIMARY KEY (id);


--
-- Name: installed_apps installed_apps_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_apps
    ADD CONSTRAINT installed_apps_pkey PRIMARY KEY (id);


--
-- Name: job_event job_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_event
    ADD CONSTRAINT job_event_pkey PRIMARY KEY (id);


--
-- Name: notification_settings notification_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_pkey PRIMARY KEY (id);


--
-- Name: notification_settings_view notification_settings_view_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings_view
    ADD CONSTRAINT notification_settings_view_pkey PRIMARY KEY (id);


--
-- Name: notification_templates notification_templates_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_templates
    ADD CONSTRAINT notification_templates_pkey PRIMARY KEY (id);


--
-- Name: notifier_event_log notifier_event_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifier_event_log
    ADD CONSTRAINT notifier_event_log_pkey PRIMARY KEY (id);


--
-- Name: pipeline_config_override pipeline_config_override_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_config_override
    ADD CONSTRAINT pipeline_config_override_pkey PRIMARY KEY (id);


--
-- Name: pipeline pipeline_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline
    ADD CONSTRAINT pipeline_pkey PRIMARY KEY (id);


--
-- Name: pipeline_strategy pipeline_strategy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_strategy
    ADD CONSTRAINT pipeline_strategy_pkey PRIMARY KEY (id);


--
-- Name: project_management_tool_config project_management_tool_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.project_management_tool_config
    ADD CONSTRAINT project_management_tool_config_pkey PRIMARY KEY (id);


--
-- Name: role_group role_group_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_group
    ADD CONSTRAINT role_group_pkey PRIMARY KEY (id);


--
-- Name: role_group_role_mapping role_group_role_mapping_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_group_role_mapping
    ADD CONSTRAINT role_group_role_mapping_pkey PRIMARY KEY (id);


--
-- Name: roles roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);


--
-- Name: ses_config ses_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ses_config
    ADD CONSTRAINT ses_config_pkey PRIMARY KEY (id);


--
-- Name: slack_config slack_config_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slack_config
    ADD CONSTRAINT slack_config_pkey PRIMARY KEY (id);


--
-- Name: team team_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_name_key UNIQUE (name);


--
-- Name: team team_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.team
    ADD CONSTRAINT team_pkey PRIMARY KEY (id);


--
-- Name: ci_artifact unique_ci_workflow_id; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_artifact
    ADD CONSTRAINT unique_ci_workflow_id UNIQUE (ci_workflow_id);


--
-- Name: event unq_event_name_type; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.event
    ADD CONSTRAINT unq_event_name_type UNIQUE (event_type);


--
-- Name: notification_templates unq_notification_template; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_templates
    ADD CONSTRAINT unq_notification_template UNIQUE (channel_type, node_type, event_type_id);


--
-- Name: notification_settings unq_source; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT unq_source UNIQUE (app_id, env_id, pipeline_id, pipeline_type, event_type_id);


--
-- Name: user_roles user_roles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: app_env_pipeline_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX app_env_pipeline_unique ON public.config_map_pipeline_level USING btree (app_id, environment_id, pipeline_id);


--
-- Name: app_env_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX app_env_unique ON public.config_map_env_level USING btree (app_id, environment_id);


--
-- Name: app_id_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX app_id_unique ON public.config_map_app_level USING btree (app_id);


--
-- Name: ds_app_name_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ds_app_name_index ON public.deployment_status USING btree (app_name);


--
-- Name: email_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX email_unique ON public.users USING btree (email_id);


--
-- Name: events_component; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_component ON public.events USING btree (component);


--
-- Name: events_creation_time_stamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_creation_time_stamp ON public.events USING btree (creation_time_stamp);


--
-- Name: events_kind; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_kind ON public.events USING btree (kind);


--
-- Name: events_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_name ON public.events USING btree (name);


--
-- Name: events_namespace; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_namespace ON public.events USING btree (namespace);


--
-- Name: events_reason; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_reason ON public.events USING btree (reason);


--
-- Name: events_resource_revision; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX events_resource_revision ON public.events USING btree (resource_revision);


--
-- Name: image_scan_deploy_info_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX image_scan_deploy_info_unique ON public.image_scan_deploy_info USING btree (scan_object_meta_id, object_type);


--
-- Name: role_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX role_unique ON public.roles USING btree (role);


--
-- Name: app_env_linkouts app_env_linkouts_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_env_linkouts
    ADD CONSTRAINT app_env_linkouts_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: app_env_linkouts app_env_linkouts_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_env_linkouts
    ADD CONSTRAINT app_env_linkouts_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environment(id);


--
-- Name: app_level_metrics app_metrics_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_level_metrics
    ADD CONSTRAINT app_metrics_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: app_store_application_version app_store_application_version_app_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store_application_version
    ADD CONSTRAINT app_store_application_version_app_store_id_fkey FOREIGN KEY (app_store_id) REFERENCES public.app_store(id);


--
-- Name: app_store app_store_chart_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store
    ADD CONSTRAINT app_store_chart_repo_id_fkey FOREIGN KEY (chart_repo_id) REFERENCES public.chart_repo(id);


--
-- Name: app_store_version_values app_store_version_values_app_store_application_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_store_version_values
    ADD CONSTRAINT app_store_version_values_app_store_application_version_id_fkey FOREIGN KEY (app_store_application_version_id) REFERENCES public.app_store_application_version(id);


--
-- Name: app app_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app
    ADD CONSTRAINT app_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id);


--
-- Name: app_workflow app_workflow_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_workflow
    ADD CONSTRAINT app_workflow_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: app_workflow_mapping app_workflow_mapping_app_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.app_workflow_mapping
    ADD CONSTRAINT app_workflow_mapping_app_workflow_id_fkey FOREIGN KEY (app_workflow_id) REFERENCES public.app_workflow(id);


--
-- Name: cd_workflow cd_workflow_ci_artifact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow
    ADD CONSTRAINT cd_workflow_ci_artifact_id_fkey FOREIGN KEY (ci_artifact_id) REFERENCES public.ci_artifact(id);


--
-- Name: cd_workflow_config cd_workflow_config_cd_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow_config
    ADD CONSTRAINT cd_workflow_config_cd_pipeline_id_fkey FOREIGN KEY (cd_pipeline_id) REFERENCES public.pipeline(id);


--
-- Name: cd_workflow cd_workflow_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow
    ADD CONSTRAINT cd_workflow_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id);


--
-- Name: cd_workflow_runner cd_workflow_runner_cd_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cd_workflow_runner
    ADD CONSTRAINT cd_workflow_runner_cd_workflow_id_fkey FOREIGN KEY (cd_workflow_id) REFERENCES public.cd_workflow(id);


--
-- Name: chart_env_config_override chart_env_config_override_chart_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_env_config_override
    ADD CONSTRAINT chart_env_config_override_chart_id_fkey FOREIGN KEY (chart_id) REFERENCES public.charts(id);


--
-- Name: chart_env_config_override chart_env_config_override_target_environment_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_env_config_override
    ADD CONSTRAINT chart_env_config_override_target_environment_fkey FOREIGN KEY (target_environment) REFERENCES public.environment(id);


--
-- Name: chart_group_deployment chart_group_deployment_chart_group_entry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_deployment
    ADD CONSTRAINT chart_group_deployment_chart_group_entry_id_fkey FOREIGN KEY (chart_group_entry_id) REFERENCES public.chart_group_entry(id);


--
-- Name: chart_group_deployment chart_group_deployment_chart_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_deployment
    ADD CONSTRAINT chart_group_deployment_chart_group_id_fkey FOREIGN KEY (chart_group_id) REFERENCES public.chart_group(id);


--
-- Name: chart_group_deployment chart_group_deployment_installed_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_deployment
    ADD CONSTRAINT chart_group_deployment_installed_app_id_fkey FOREIGN KEY (installed_app_id) REFERENCES public.installed_apps(id);


--
-- Name: chart_group_entry chart_group_entry_app_store_application_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_entry
    ADD CONSTRAINT chart_group_entry_app_store_application_version_id_fkey FOREIGN KEY (app_store_application_version_id) REFERENCES public.app_store_application_version(id);


--
-- Name: chart_group_entry chart_group_entry_app_store_values_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_entry
    ADD CONSTRAINT chart_group_entry_app_store_values_version_id_fkey FOREIGN KEY (app_store_values_version_id) REFERENCES public.app_store_version_values(id);


--
-- Name: chart_group_entry chart_group_entry_chart_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chart_group_entry
    ADD CONSTRAINT chart_group_entry_chart_group_id_fkey FOREIGN KEY (chart_group_id) REFERENCES public.chart_group(id);


--
-- Name: charts charts_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charts
    ADD CONSTRAINT charts_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: charts charts_chart_repo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.charts
    ADD CONSTRAINT charts_chart_repo_id_fkey FOREIGN KEY (chart_repo_id) REFERENCES public.chart_repo(id);


--
-- Name: ci_artifact ci_artifact_ci_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_artifact
    ADD CONSTRAINT ci_artifact_ci_workflow_id_fkey FOREIGN KEY (ci_workflow_id) REFERENCES public.ci_workflow(id);


--
-- Name: ci_artifact ci_artifact_parent_ci_artifact_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_artifact
    ADD CONSTRAINT ci_artifact_parent_ci_artifact_fkey FOREIGN KEY (parent_ci_artifact) REFERENCES public.ci_artifact(id);


--
-- Name: ci_artifact ci_artifact_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_artifact
    ADD CONSTRAINT ci_artifact_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: ci_pipeline ci_pipeline_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline
    ADD CONSTRAINT ci_pipeline_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: ci_pipeline ci_pipeline_ci_template_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline
    ADD CONSTRAINT ci_pipeline_ci_template_id_fkey FOREIGN KEY (ci_template_id) REFERENCES public.ci_template(id);


--
-- Name: ci_pipeline_material ci_pipeline_material_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_material
    ADD CONSTRAINT ci_pipeline_material_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: ci_pipeline_material ci_pipeline_material_git_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_material
    ADD CONSTRAINT ci_pipeline_material_git_material_id_fkey FOREIGN KEY (git_material_id) REFERENCES public.git_material(id);


--
-- Name: ci_pipeline ci_pipeline_parent_ci_pipeline_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline
    ADD CONSTRAINT ci_pipeline_parent_ci_pipeline_fkey FOREIGN KEY (parent_ci_pipeline) REFERENCES public.ci_pipeline(id);


--
-- Name: ci_pipeline_scripts ci_pipeline_scripts_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_pipeline_scripts
    ADD CONSTRAINT ci_pipeline_scripts_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: ci_template ci_template_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_template
    ADD CONSTRAINT ci_template_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: ci_template ci_template_docker_registry_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_template
    ADD CONSTRAINT ci_template_docker_registry_id_fkey FOREIGN KEY (docker_registry_id) REFERENCES public.docker_artifact_store(id);


--
-- Name: ci_template ci_template_git_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_template
    ADD CONSTRAINT ci_template_git_material_id_fkey FOREIGN KEY (git_material_id) REFERENCES public.git_material(id);


--
-- Name: ci_workflow ci_workflow_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow
    ADD CONSTRAINT ci_workflow_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: ci_workflow_config ci_workflow_config_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ci_workflow_config
    ADD CONSTRAINT ci_workflow_config_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: cluster_accounts cluster_accounts_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_accounts
    ADD CONSTRAINT cluster_accounts_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES public.cluster(id);


--
-- Name: cluster_helm_config cluster_helm_config_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_helm_config
    ADD CONSTRAINT cluster_helm_config_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES public.cluster(id);


--
-- Name: cluster_installed_apps cluster_installed_apps_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_installed_apps
    ADD CONSTRAINT cluster_installed_apps_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES public.cluster(id);


--
-- Name: cluster_installed_apps cluster_installed_apps_installed_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cluster_installed_apps
    ADD CONSTRAINT cluster_installed_apps_installed_app_id_fkey FOREIGN KEY (installed_app_id) REFERENCES public.installed_apps(id);


--
-- Name: config_map_app_level config_map_app_level_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_map_app_level
    ADD CONSTRAINT config_map_app_level_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: config_map_env_level config_map_env_level_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_map_env_level
    ADD CONSTRAINT config_map_env_level_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: config_map_env_level config_map_env_level_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_map_env_level
    ADD CONSTRAINT config_map_env_level_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environment(id);


--
-- Name: config_map_pipeline_level config_map_pipeline_level_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_map_pipeline_level
    ADD CONSTRAINT config_map_pipeline_level_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: config_map_pipeline_level config_map_pipeline_level_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_map_pipeline_level
    ADD CONSTRAINT config_map_pipeline_level_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environment(id);


--
-- Name: config_map_pipeline_level config_map_pipeline_level_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.config_map_pipeline_level
    ADD CONSTRAINT config_map_pipeline_level_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id);


--
-- Name: cve_policy_control cve_policy_control_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve_policy_control
    ADD CONSTRAINT cve_policy_control_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: cve_policy_control cve_policy_control_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve_policy_control
    ADD CONSTRAINT cve_policy_control_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES public.cluster(id);


--
-- Name: cve_policy_control cve_policy_control_cve_store_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve_policy_control
    ADD CONSTRAINT cve_policy_control_cve_store_id_fkey FOREIGN KEY (cve_store_id) REFERENCES public.cve_store(name);


--
-- Name: cve_policy_control cve_policy_control_env_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cve_policy_control
    ADD CONSTRAINT cve_policy_control_env_id_fkey FOREIGN KEY (env_id) REFERENCES public.environment(id);


--
-- Name: db_migration_config db_migration_config_db_config_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_migration_config
    ADD CONSTRAINT db_migration_config_db_config_id_fkey FOREIGN KEY (db_config_id) REFERENCES public.db_config(id);


--
-- Name: db_migration_config db_migration_config_git_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_migration_config
    ADD CONSTRAINT db_migration_config_git_material_id_fkey FOREIGN KEY (git_material_id) REFERENCES public.git_material(id);


--
-- Name: db_migration_config db_migration_config_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.db_migration_config
    ADD CONSTRAINT db_migration_config_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id);


--
-- Name: deployment_group_app deployment_group_app_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group_app
    ADD CONSTRAINT deployment_group_app_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: deployment_group_app deployment_group_app_deployment_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group_app
    ADD CONSTRAINT deployment_group_app_deployment_group_id_fkey FOREIGN KEY (deployment_group_id) REFERENCES public.deployment_group(id);


--
-- Name: deployment_group deployment_group_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group
    ADD CONSTRAINT deployment_group_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: deployment_group deployment_group_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_group
    ADD CONSTRAINT deployment_group_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environment(id);


--
-- Name: deployment_status deployment_status_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_status
    ADD CONSTRAINT deployment_status_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: deployment_status deployment_status_env_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.deployment_status
    ADD CONSTRAINT deployment_status_env_id_fkey FOREIGN KEY (env_id) REFERENCES public.environment(id);


--
-- Name: env_level_app_metrics env_level_env_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.env_level_app_metrics
    ADD CONSTRAINT env_level_env_id_fkey FOREIGN KEY (env_id) REFERENCES public.environment(id);


--
-- Name: env_level_app_metrics env_metrics_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.env_level_app_metrics
    ADD CONSTRAINT env_metrics_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: environment environment_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.environment
    ADD CONSTRAINT environment_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES public.cluster(id);


--
-- Name: external_ci_pipeline external_ci_pipeline_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.external_ci_pipeline
    ADD CONSTRAINT external_ci_pipeline_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: git_material git_material_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_material
    ADD CONSTRAINT git_material_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: git_material git_material_git_provider_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_material
    ADD CONSTRAINT git_material_git_provider_id_fkey FOREIGN KEY (git_provider_id) REFERENCES public.git_provider(id);


--
-- Name: git_web_hook git_web_hook_ci_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_web_hook
    ADD CONSTRAINT git_web_hook_ci_material_id_fkey FOREIGN KEY (ci_material_id) REFERENCES public.ci_pipeline_material(id);


--
-- Name: git_web_hook git_web_hook_git_material_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.git_web_hook
    ADD CONSTRAINT git_web_hook_git_material_id_fkey FOREIGN KEY (git_material_id) REFERENCES public.git_material(id);


--
-- Name: image_scan_deploy_info image_scan_deploy_info_cluster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_deploy_info
    ADD CONSTRAINT image_scan_deploy_info_cluster_id_fkey FOREIGN KEY (cluster_id) REFERENCES public.cluster(id);


--
-- Name: image_scan_deploy_info image_scan_deploy_info_env_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_deploy_info
    ADD CONSTRAINT image_scan_deploy_info_env_id_fkey FOREIGN KEY (env_id) REFERENCES public.environment(id);


--
-- Name: image_scan_deploy_info image_scan_deploy_info_scan_object_meta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_deploy_info
    ADD CONSTRAINT image_scan_deploy_info_scan_object_meta_id_fkey FOREIGN KEY (scan_object_meta_id) REFERENCES public.image_scan_object_meta(id);


--
-- Name: image_scan_execution_result image_scan_execution_result_cve_store_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_execution_result
    ADD CONSTRAINT image_scan_execution_result_cve_store_name_fkey FOREIGN KEY (cve_store_name) REFERENCES public.cve_store(name);


--
-- Name: image_scan_execution_result image_scan_execution_result_image_scan_execution_history_i_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.image_scan_execution_result
    ADD CONSTRAINT image_scan_execution_result_image_scan_execution_history_i_fkey FOREIGN KEY (image_scan_execution_history_id) REFERENCES public.image_scan_execution_history(id);


--
-- Name: installed_app_versions installed_app_versions_app_store_application_version_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_app_versions
    ADD CONSTRAINT installed_app_versions_app_store_application_version_id_fkey FOREIGN KEY (app_store_application_version_id) REFERENCES public.app_store_application_version(id);


--
-- Name: installed_app_versions installed_app_versions_installed_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_app_versions
    ADD CONSTRAINT installed_app_versions_installed_app_id_fkey FOREIGN KEY (installed_app_id) REFERENCES public.installed_apps(id);


--
-- Name: installed_apps installed_apps_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_apps
    ADD CONSTRAINT installed_apps_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: installed_apps installed_apps_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.installed_apps
    ADD CONSTRAINT installed_apps_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environment(id);


--
-- Name: notification_settings notification_settings_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: notification_settings notification_settings_env_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_env_id_fkey FOREIGN KEY (env_id) REFERENCES public.environment(id);


--
-- Name: notification_templates notification_settings_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_templates
    ADD CONSTRAINT notification_settings_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.event(id);


--
-- Name: notification_settings notification_settings_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.event(id);


--
-- Name: notification_settings notification_settings_event_view_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_event_view_id_fkey FOREIGN KEY (view_id) REFERENCES public.notification_settings_view(id);


--
-- Name: notification_settings notification_settings_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notification_settings
    ADD CONSTRAINT notification_settings_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.team(id);


--
-- Name: notifier_event_log notifier_event_log_event_type_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifier_event_log
    ADD CONSTRAINT notifier_event_log_event_type_id_fkey FOREIGN KEY (event_type_id) REFERENCES public.event(id);


--
-- Name: pipeline pipeline_app_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline
    ADD CONSTRAINT pipeline_app_id_fkey FOREIGN KEY (app_id) REFERENCES public.app(id);


--
-- Name: pipeline pipeline_ci_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline
    ADD CONSTRAINT pipeline_ci_pipeline_id_fkey FOREIGN KEY (ci_pipeline_id) REFERENCES public.ci_pipeline(id);


--
-- Name: pipeline_config_override pipeline_config_override_cd_workflow_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_config_override
    ADD CONSTRAINT pipeline_config_override_cd_workflow_id_fkey FOREIGN KEY (cd_workflow_id) REFERENCES public.cd_workflow(id);


--
-- Name: pipeline_config_override pipeline_config_override_ci_artifact_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_config_override
    ADD CONSTRAINT pipeline_config_override_ci_artifact_id_fkey FOREIGN KEY (ci_artifact_id) REFERENCES public.ci_artifact(id);


--
-- Name: pipeline_config_override pipeline_config_override_env_config_override_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_config_override
    ADD CONSTRAINT pipeline_config_override_env_config_override_id_fkey FOREIGN KEY (env_config_override_id) REFERENCES public.chart_env_config_override(id);


--
-- Name: pipeline_config_override pipeline_config_override_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_config_override
    ADD CONSTRAINT pipeline_config_override_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id);


--
-- Name: pipeline pipeline_environment_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline
    ADD CONSTRAINT pipeline_environment_id_fkey FOREIGN KEY (environment_id) REFERENCES public.environment(id);


--
-- Name: pipeline_strategy pipeline_strategy_pipeline_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pipeline_strategy
    ADD CONSTRAINT pipeline_strategy_pipeline_id_fkey FOREIGN KEY (pipeline_id) REFERENCES public.pipeline(id);


--
-- Name: role_group_role_mapping role_group_role_mapping_role_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_group_role_mapping
    ADD CONSTRAINT role_group_role_mapping_role_group_id_fkey FOREIGN KEY (role_group_id) REFERENCES public.role_group(id);


--
-- Name: role_group_role_mapping role_group_role_mapping_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.role_group_role_mapping
    ADD CONSTRAINT role_group_role_mapping_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: ses_config ses_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ses_config
    ADD CONSTRAINT ses_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


--
-- Name: slack_config slack_team_name_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slack_config
    ADD CONSTRAINT slack_team_name_fkey FOREIGN KEY (team_id) REFERENCES public.team(id);


--
-- Name: user_roles user_roles_role_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);


--
-- Name: user_roles user_roles_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.user_roles
    ADD CONSTRAINT user_roles_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: slack_config users_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slack_config
    ADD CONSTRAINT users_fkey FOREIGN KEY (owner_id) REFERENCES public.users(id);


INSERT INTO "public"."chart_ref" ("id", "location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('10', 'reference-chart_3-9-0', '3.9.0', 't', 't', 'now()', '1', 'now()', '1'),
('9', 'reference-chart_3-8-0', '3.8.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('1', 'reference-app-rolling', '2.0.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('2', 'reference-chart_3-1-0', '3.1.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('3', 'reference-chart_3-2-0', '3.2.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('4', 'reference-chart_3-3-0', '3.3.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('5', 'reference-chart_3-4-0', '3.4.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('6', 'reference-chart_3-5-0', '3.5.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('7', 'reference-chart_3-6-0', '3.6.0', 'f', 'f', 'now()', '1', 'now()', '1'),
('8', 'reference-chart_3-7-0', '3.7.0', 'f', 'f', 'now()', '1', 'now()', '1');



INSERT INTO "public"."chart_repo" ("id", "name", "url", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by", "external") VALUES
('1', 'default-chartmuseum', 'http://devtron-chartmuseum.devtroncd:8080/', 't', 't', 'now()', '1', 'now()', '1', 'f'),
('2', 'devtron', 'https://helm.devtron.ai', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('3', 'jetstack', 'https://charts.jetstack.io', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('4', 'elastic', 'https://helm.elastic.co', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('5', 'autoscaler', 'https://kubernetes.github.io/autoscaler', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('6', 'fluent', 'https://fluent.github.io/helm-charts', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('7', 'nginx-ingress', 'https://kubernetes.github.io/ingress-nginx', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('8', 'metrics-server', 'https://kubernetes-sigs.github.io/metrics-server', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('9', 'prometheus-community', 'https://prometheus-community.github.io/helm-charts', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('10', 'bitnami', 'https://charts.bitnami.com/bitnami', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('11', 'external-secrets', 'https://charts.external-secrets.io', 'f', 't', 'now()', '1', 'now()', '1', 't'),
('12', 'kedacore', 'https://kedacore.github.io/charts', 'f', 't', 'now()', '1', 'now()', '1', 't');


INSERT INTO "public"."cluster" ("id", "cluster_name", "active", "created_on", "created_by", "updated_on", "updated_by", "server_url", "config", "prometheus_endpoint", "cd_argo_setup", "p_username", "p_password", "p_tls_client_cert", "p_tls_client_key") VALUES
('1', 'default_cluster', 't', 'now()', '1', 'now()', '1', 'https://kubernetes.default.svc', '{}', NULL, 'f', NULL, NULL, NULL, NULL);

INSERT INTO "public"."cve_policy_control" ("id", "global", "cluster_id", "env_id", "app_id", "cve_store_id", "action", "severity", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 't', NULL, NULL, NULL, NULL, '1', '2', 'f', 'now()', '1', 'now()', '1'),
('2', 't', NULL, NULL, NULL, NULL, '1', '1', 'f', 'now()', '1', 'now()', '1'),
('3', 't', NULL, NULL, NULL, NULL, '1', '0', 'f', 'now()', '1', 'now()', '1');

INSERT INTO "public"."event" ("id", "event_type", "description") VALUES
('1', 'TRIGGER', ''),
('2', 'SUCCESS', ''),
('3', 'FAIL', '');

INSERT INTO "public"."notification_templates" ("id", "channel_type", "node_type", "event_type_id", "template_name", "template_payload") VALUES
('1', 'slack', 'CI', '1', 'CI trigger template', '{
    "text": ":arrow_forward: Build pipeline Triggered |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":arrow_forward: *Build Pipeline triggered*\n{{eventTime}} \n Triggered by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url": "https://github.com/devtron-labs/wp-content/uploads/2020/06/img-build-notification@2x.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Pipeline*\n{{pipelineName}}"
                }
            ]
        },
        {{#ciMaterials}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/ciMaterials}}
        {
            "type": "actions",
            "elements": [{
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "View Details"
                }
                {{#buildHistoryLink}}
                    ,
                    "url": "{{& buildHistoryLink}}"
                {{/buildHistoryLink}}
            }]
        }
    ]
}'),
('2', 'ses', 'CI', '1', 'CI trigger ses template', '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI triggered for app: {{appName}}",
 "html": "<b>CI triggered on pipeline: {{pipelineName}}</b>"
}'),
('3', 'slack', 'CI', '2', 'CI success template', '{
  "text": ":tada: Build pipeline Successful |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "\n"
      }
    },
    {
      "type": "divider"
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ":tada: *Build Pipeline successful*\n{{eventTime}} \n Triggered by {{triggeredBy}}"
      },
      "accessory": {
        "type": "image",
        "image_url": "https://github.com/devtron-labs/wp-content/uploads/2020/06/img-build-notification@2x.png",
        "alt_text": "calendar thumbnail"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Application*\n{{appName}}"
        },
        {
          "type": "mrkdwn",
          "text": "*Pipeline*\n{{pipelineName}}"
        }
      ]
    },
    {{#ciMaterials}}
     {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
           "text": "*Branch*\n`{{appName}}/{{branch}}`"
        },
        {
          "type": "mrkdwn",
          "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
        }
      ]
    },
    {{/ciMaterials}}
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "View Details"
          }
          {{#buildHistoryLink}}
            ,
            "url": "{{& buildHistoryLink}}"
          {{/buildHistoryLink}}
        }
      ]
    }
  ]
}'),
('4', 'ses', 'CI', '2', 'CI success ses template', '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI success for app: {{appName}}",
 "html": "<b>CI success on pipeline: {{pipelineName}}</b><br><b>docker image: {{{dockerImageUrl}}}</b><br><b>Source: {{source}}</b><br>"
}'),
('5', 'slack', 'CI', '3', 'CI fail template', '{
    "text": ":x: Build pipeline Failed |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":x: *Build Pipeline failed*\n{{eventTime}} \n Triggered by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url": "https://github.com/devtron-labs/wp-content/uploads/2020/06/img-build-notification@2x.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Pipeline*\n{{pipelineName}}"
                }
            ]
        },
        {{#ciMaterials}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/ciMaterials}}
        {
            "type": "actions",
            "elements": [{
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "View Details"
                }
                  {{#buildHistoryLink}}
                    ,
                    "url": "{{& buildHistoryLink}}"
                   {{/buildHistoryLink}}
            }]
        }
    ]
}'),
('6', 'ses', 'CI', '3', 'CI failed ses template', '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI failed for app: {{appName}}",
 "html": "<b>CI failed on pipeline: {{pipelineName}}</b><br><b>build name: {{buildName}}</b><br><b>Pod status: {{podStatus}}</b><br><b>message: {{message}}</b>"
}'),
('7', 'slack', 'CD', '1', 'CD trigger template', '{
    "text": ":arrow_forward: Deployment pipeline Triggered |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":arrow_forward: *Deployment Pipeline triggered on {{envName}}*\n{{eventTime}} \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/wp-content/uploads/2020/06/img-deployment-notification@2x.png",
                "alt_text": "Deploy Pipeline Triggered"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
             "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'),
('8', 'ses', 'CD', '1', 'CD trigger ses template', '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD triggered for app: {{appName}} on environment: {{environmentName}}",
 "html": "<b>CD triggered for app: {{appName}} on environment: {{environmentName}}</b> <br> <b>Docker image: {{{dockerImageUrl}}}</b> <br> <b>Source snapshot: {{source}}</b> <br> <b>pipeline: {{pipelineName}}</b>"
}'),
('9', 'slack', 'CD', '2', 'CD success template', '{
    "text": ":tada: Deployment pipeline Successful |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":tada: *Deployment Pipeline successful on {{envName}}*\n{{eventTime}} \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/wp-content/uploads/2020/06/img-deployment-notification@2x.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
             "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'),
('10', 'ses', 'CD', '2', 'CD success ses template', '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD success for app: {{appName}} on environment: {{environmentName}}",
 "html": "<b>CD success for app: {{appName}} on environment: {{environmentName}}</b>"
}'),
('11', 'slack', 'CD', '3', 'CD failed template', '{
    "text": ":x: Deployment pipeline Failed |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":x: *Deployment Pipeline failed on {{envName}}*\n{{eventTime}} \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/wp-content/uploads/2020/06/img-deployment-notification@2x.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'),
('12', 'ses', 'CD', '3', 'CD failed ses template', '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD failed for app: {{appName}} on environment: {{environmentName}}",
 "html": "<b>CD failed for app: {{appName}} on environment: {{environmentName}}</b>"
}');

INSERT INTO "public"."roles" ("id", "role", "team", "environment", "entity_name", "action", "created_by", "created_on", "updated_by", "updated_on", "entity") VALUES
('1', 'role:super-admin___', NULL, NULL, NULL, 'super-admin', NULL, NULL, NULL, NULL, NULL);

INSERT INTO "public"."users" ("id", "fname", "lname", "password", "access_token", "created_on", "email_id", "created_by", "updated_by", "updated_on", "active") VALUES
('1', NULL, NULL, NULL, NULL, NULL, 'system', NULL, NULL, NULL, 't'),
('2', NULL, NULL, NULL, NULL, NULL, 'admin', NULL, NULL, NULL, 't');

INSERT INTO "public"."user_roles" ("id", "user_id", "role_id", "created_by", "created_on", "updated_by", "updated_on") VALUES
('1', '2', '1', NULL, NULL, NULL, NULL);

INSERT INTO "public"."git_provider" ("id", "name", "url", "user_name", "password", "ssh_key", "access_token", "auth_mode", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'Github Public', 'github.com', NULL, NULL, NULL, NULL, 'ANONYMOUS', 't', 'now()', '1', 'now()', '1');

INSERT INTO "public"."team" ("id", "name", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'devtron-demo', 't', 'now()', '1', 'now()', '1');

INSERT INTO "public"."environment" ("id", "environment_name", "cluster_id", "active", "created_on", "created_by", "updated_on", "updated_by", "default", "namespace", "grafana_datasource_id") VALUES

('1', 'devtron-demo', '1', 't', 'now()', '1', 'now()', '1', 'f', 'devtron-demo', '1');

--
-- PostgreSQL database dump complete
--
--
-- Name: webhook_event_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.webhook_event_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE CACHE 1;


--
-- Name: webhook_event_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.webhook_event_data
(
    id           INTEGER                NOT NULL DEFAULT nextval('webhook_event_data_id_seq'::regclass),
    git_host_id  INTEGER                NOT NULL,
    event_type   character varying(250) NOT NULL,
    payload_json JSON                   NOT NULL,
    created_on   timestamptz            NOT NULL,
    PRIMARY KEY ("id")
);


---- Add Foreign key constraint on git_host_id in Table webhook_event_data
ALTER TABLE webhook_event_data
    ADD CONSTRAINT webhook_event_data_ghid_fkey FOREIGN KEY (git_host_id) REFERENCES public.git_host(id);
CREATE SEQUENCE IF NOT EXISTS id_seq_app_label;

-- Table Definition
CREATE TABLE "public"."app_label"
(
    "id"         int4         NOT NULL DEFAULT nextval('id_seq_app_label'::regclass),
    "app_id"     int4         NOT NULL,
    "key"        varchar(255) NOT NULL,
    "value"      varchar(255) NOT NULL,
    "created_on" timestamptz,
    "created_by" int4,
    "updated_on" timestamptz,
    "updated_by" int4,
    CONSTRAINT "app_label_app_id_fkey" FOREIGN KEY ("app_id") REFERENCES "public"."app" ("id"),
    PRIMARY KEY ("id")
);ALTER TABLE docker_artifact_store
ALTER COLUMN password type character varying(5000)UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_3-12-0', '3.12.0', 't', 't', 'now()', 1, 'now()', 1);ALTER TABLE "public"."docker_artifact_store" ADD COLUMN "connection" varchar(250);

ALTER TABLE "public"."docker_artifact_store" ADD COLUMN "cert" text;---- ALTER TABLE git_provider - modify type
ALTER TABLE git_provider
ALTER COLUMN ssh_key TYPE text;

---- ALTER TABLE git_provider - rename column
ALTER TABLE git_provider
RENAME COLUMN ssh_key TO ssh_private_key;

---- ALTER TABLE git_material - add column
ALTER TABLE git_material
ADD COLUMN fetch_submodules bool NOT NULL DEFAULT FALSE;---- ALTER TABLE gitops_config - add column
ALTER TABLE gitops_config
    ADD COLUMN bitbucket_workspace_id TEXT,
    ADD COLUMN bitbucket_project_key TEXT;
UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_4-10-0', '4.10.0', 't', 't', 'now()', 1, 'now()', 1);
ALTER TABLE "public"."chart_ref" ADD COLUMN IF NOT EXISTS "name" varchar(250);

ALTER TABLE "public"."chart_ref" ADD COLUMN IF NOT EXISTS "chart_data" bytea;INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by", "name") VALUES
('cronjob-chart_1-2-0', '1.2.0', 'f', 'f', 'now()', 1, 'now()', 1, 'Cron Job & Job');
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by", "name") VALUES
('knative-chart_1-1-0', '1.1.0', 'f', 'f', 'now()', 1, 'now()', 1, 'Knative');ALTER TABLE "public"."installed_app_versions" DROP COLUMN "values_yaml";UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_4-11-0', '4.11.0', 't', 't', 'now()', 1, 'now()', 1);
ALTER TABLE "public"."roles"
    ADD COLUMN IF NOT EXISTS "access_type" character varying(100);

DROP INDEX "public"."role_unique";

CREATE UNIQUE INDEX IF NOT EXISTS "role_unique" ON "public"."roles" USING BTREE ("role","access_type");ALTER TABLE "public"."environment" ADD COLUMN IF NOT EXISTS "environment_identifier" varchar(250);
UPDATE environment SET environment_identifier = e2.environment_name FROM environment e2 WHERE e2.id = environment.id AND environment.environment_identifier IS NULL;
ALTER TABLE environment ALTER COLUMN environment_identifier SET NOT NULL;-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_default_auth_policy;

-- Table Definition
CREATE TABLE "public"."default_auth_policy" (
                                          "id" int NOT NULL DEFAULT nextval('id_seq_default_auth_policy'::regclass),
                                          "role_type" varchar(250) NOT NULL,
                                          "policy" text NOT NULL,
                                          "created_on" timestamptz,
                                          "created_by" integer,
                                          "updated_on" timestamptz,
                                          "updated_by" integer,
                                          PRIMARY KEY ("id")
);

INSERT INTO "public"."default_auth_policy" ("id", "role_type", "policy", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'manager', '{
    "data": [
        {
            "type": "p",
            "sub": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "applications",
            "act": "*",
            "obj": "{{.TeamObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "environment",
            "act": "*",
            "obj": "{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "*",
            "obj": "{{.TeamObj}}"
        },
        {
            "type": "p",
            "sub": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "user",
            "act": "*",
            "obj": "{{.TeamObj}}"
        },
        {
            "type": "p",
            "sub": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "notification",
            "act": "*",
            "obj": "{{.TeamObj}}"
        },
        {
            "type": "p",
            "sub": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "*",
            "obj": "{{.EnvObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('2', 'admin', '{
    "data": [
        {
            "type": "p",
            "sub": "role:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "applications",
            "act": "*",
            "obj": "{{.TeamObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "environment",
            "act": "*",
            "obj": "{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "get",
            "obj": "{{.TeamObj}}"
        },
        {
            "type": "p",
            "sub": "role:admin_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "get",
            "obj": "{{.EnvObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('3', 'trigger', '{
    "data": [
        {
            "type": "p",
            "sub": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "applications",
            "act": "get",
            "obj": "{{.TeamObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "applications",
            "act": "trigger",
            "obj": "{{.TeamObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "environment",
            "act": "trigger",
            "obj": "{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "environment",
            "act": "get",
            "obj": "{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "get",
            "obj": "{{.EnvObj}}"
        },
        {
            "type": "p",
            "sub": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "get",
            "obj": "{{.TeamObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('4', 'view', '{
    "data": [
        {
            "type": "p",
            "sub": "role:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "applications",
            "act": "get",
            "obj": "{{.TeamObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "environment",
            "act": "get",
            "obj": "{{.EnvObj}}/{{.AppObj}}"
        },
        {
            "type": "p",
            "sub": "role:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "global-environment",
            "act": "get",
            "obj": "{{.EnvObj}}"
        },
        {
            "type": "p",
            "sub": "role:view_{{.Team}}_{{.Env}}_{{.App}}",
            "res": "team",
            "act": "get",
            "obj": "{{.TeamObj}}"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('5', 'entityAll', '{
    "data": [
        {
            "type": "p",
            "sub": "role:{{.Entity}}_admin",
            "res": "{{.Entity}}",
            "act": "*",
            "obj": "*"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('6', 'entityView','{
    "data": [
        {
            "type": "p",
            "sub": "role:{{.Entity}}_view",
            "res": "{{.Entity}}",
            "act": "get",
            "obj": "*"
        }
    ]
}', 'now()', '1', 'now()', '1'),
('7', 'entitySpecific','{
    "data": [
        {
            "type": "p",
            "sub": "role:{{.Entity}}_{{.EntityName}}_specific",
            "res": "{{.Entity}}",
            "act": "update",
            "obj": "{{.EntityName}}"
        },
       {
            "type": "p",
            "sub": "role:{{.Entity}}_{{.EntityName}}_specific",
            "res": "{{.Entity}}",
            "act": "get",
            "obj": "{{.EntityName}}"
        }
    ]
}', 'now()', '1', 'now()', '1');




-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_default_auth_role;

-- Table Definition
CREATE TABLE "public"."default_auth_role" (
                                        "id" int NOT NULL DEFAULT nextval('id_seq_default_auth_role'::regclass),
                                        "role_type" varchar(250) NOT NULL,
                                        "role" text NOT NULL,
                                        "created_on" timestamptz,
                                        "created_by" integer,
                                        "updated_on" timestamptz,
                                        "updated_by" integer,
                                        PRIMARY KEY ("id")
);

INSERT INTO "public"."default_auth_role" ("id", "role_type", "role", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'manager', '{
    "role": "role:manager_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:manager_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "manager",
    "access_type": ""
}', 'now()', '1', 'now()', '1'),
('2', 'admin', '{
    "role": "role:admin_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:admin_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "admin",
    "access_type": ""
}', 'now()', '1', 'now()', '1'),
('3', 'trigger', '{
    "role": "role:trigger_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:trigger_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "trigger",
    "access_type": ""
}', 'now()', '1', 'now()', '1'),
('4', 'view', '{
    "role": "role:view_{{.Team}}_{{.Env}}_{{.App}}",
    "casbinSubjects": [
        "role:view_{{.Team}}_{{.Env}}_{{.App}}"
    ],
    "team": "{{.Team}}",
    "entityName": "{{.App}}",
    "environment": "{{.Env}}",
    "action": "view",
    "access_type": ""
}', 'now()', '1', 'now()', '1'),
('5', 'entitySpecificAdmin', '{
    "role": "role:{{.Entity}}_admin",
    "casbinSubjects": [
        "role:{{.Entity}}_admin"
    ],
    "entity": "{{.Entity}}",
    "team": "",
    "application": "",
    "environment": "",
    "action": "admin"
}', 'now()', '1', 'now()', '1'),
('6', 'entitySpecificView', '{
    "role": "role:{{.Entity}}_view",
    "casbinSubjects": [
        "role:{{.Entity}}_view"
    ],
    "entity": "{{.Entity}}",
    "team": "",
    "application": "",
    "environment": "",
    "action": "view"
}', 'now()', '1', 'now()', '1'),
('7', 'roleSpecific', '{
    "role": "role:{{.Entity}}_{{.EntityName}}_specific",
    "casbinSubjects": [
        "role:{{.Entity}}_{{.EntityName}}_specific"
    ],
    "entity": "{{.Entity}}",
    "team": "",
    "entityName": "{{.EntityName}}",
    "environment": "",
    "action": "update"
}', 'now()', '1', 'now()', '1');ALTER TABLE chart_group ADD COLUMN deleted bool NOT NULL DEFAULT FALSE;

ALTER TABLE chart_repo ADD COLUMN deleted bool NOT NULL DEFAULT FALSE;

ALTER TABLE slack_config ADD COLUMN deleted bool NOT NULL DEFAULT FALSE;

ALTER TABLE ses_config ADD COLUMN deleted bool NOT NULL DEFAULT FALSE;

ALTER TABLE git_provider ADD COLUMN deleted bool NOT NULL DEFAULT FALSE;

ALTER TABLE team DROP CONSTRAINT team_name_key;

ALTER TABLE git_provider DROP CONSTRAINT git_provider_name_key;

ALTER TABLE git_provider DROP CONSTRAINT git_provider_url_key;

ALTER TABLE chart_group DROP CONSTRAINT chart_group_name_key;----Dropping tables which are not being used and are not deleted earlier by migration

DROP TABLE IF EXISTS casbin_role CASCADE;

DROP TABLE IF EXISTS casbin CASCADE;

DROP TABLE IF EXISTS external_apps CASCADE;

DROP TABLE IF EXISTS pipeline_config CASCADE;ALTER TABLE app
ADD COLUMN IF NOT EXISTS app_offering_mode varchar(50) NOT NULL DEFAULT 'FULL';ALTER TABLE "public"."installed_apps" ADD COLUMN "git_ops_repo_name" varchar(255);CREATE SEQUENCE IF NOT EXISTS id_seq_config_map_history;

-- Table Definition
CREATE TABLE "public"."config_map_history"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_config_map_history'::regclass),
    "pipeline_id"                 integer,
    "app_id"                      integer,
    "data_type"                   varchar(255),
    "data"                        text,
    "deployed"                    boolean,
    "deployed_on"                 timestamptz,
    "deployed_by"                 int4,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "config_map_history_pipeline_id_fkey" FOREIGN KEY ("pipeline_id") REFERENCES "public"."pipeline" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_deployment_template_history;

-- Table Definition
CREATE TABLE "public"."deployment_template_history"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_deployment_template_history'::regclass),
    "pipeline_id"                   integer,
    "app_id"                        integer,
    "target_environment"            integer,
    "image_descriptor_template"     text NOT NULL,
    "template"                      text NOT NULL,
    "template_name"                 text,
    "template_version"              text,
    "is_app_metrics_enabled"        bool,
    "deployed"                      bool,
    "deployed_on"                   timestamptz,
    "deployed_by"                   int4,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "deployment_template_history_pipeline_id_fkey" FOREIGN KEY ("pipeline_id") REFERENCES "public"."pipeline" ("id"),
    PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_app_store_charts_history;

-- Table Definition
CREATE TABLE "public"."app_store_charts_history"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_app_store_charts_history'::regclass),
    "installed_apps_id"             integer NOT NULL,
    "values_yaml"                   text,
    "deployed_on"                   timestamptz,
    "deployed_by"                   int4,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "app_store_charts_history_installed_apps_id_fkey" FOREIGN KEY ("installed_apps_id") REFERENCES "public"."installed_apps" ("id"),
    PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_pre_post_ci_script_history;

-- Table Definition
CREATE TABLE "public"."pre_post_ci_script_history"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_pre_post_ci_script_history'::regclass),
    "ci_pipeline_scripts_id"        integer NOT NULL,
    "script"                        text,
    "stage"                         text,
    "name"                          text,
    "output_location"               text,
    "built"                         bool,
    "built_on"                      timestamptz,
    "built_by"                      int4,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "pre_post_ci_script_history_ci_pipeline_scripts_id_fkey" FOREIGN KEY ("ci_pipeline_scripts_id") REFERENCES "public"."ci_pipeline_scripts" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_pre_post_cd_script_history;

-- Table Definition
CREATE TABLE "public"."pre_post_cd_script_history"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_pre_post_cd_script_history'::regclass),
    "pipeline_id"                   integer NOT NULL,
    "script"                        text,
    "stage"                         text,
    "configmap_secret_names"        text,
    "configmap_data"                text,
    "secret_data"                   text,
    "exec_in_env"                   bool,
    "trigger_type"                  text,
    "deployed"                      bool,
    "deployed_on"                   timestamptz,
    "deployed_by"                   int4,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "pre_post_cd_script_history_pipeline_id_fkey" FOREIGN KEY ("pipeline_id") REFERENCES "public"."pipeline" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_strategy_history;

-- Table Definition
CREATE TABLE "public"."pipeline_strategy_history"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_pipeline_strategy_history'::regclass),
    "pipeline_id"                   integer NOT NULL,
    "config"                        text,
    "strategy"                      text NOT NULL ,
    "default"                       bool,
    "deployed"                      bool,
    "deployed_on"                   timestamptz,
    "deployed_by"                   int4,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "pipeline_strategy_history_pipeline_id_fkey" FOREIGN KEY ("pipeline_id") REFERENCES "public"."pipeline" ("id"),
    PRIMARY KEY ("id")
);-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_installed_app_version_history;

-- Table Definition
CREATE TABLE "public"."installed_app_version_history" (
                                                          "id" int4 NOT NULL DEFAULT nextval('id_seq_installed_app_version_history'::regclass),
                                                          "installed_app_version_id" int4 NOT NULL,
                                                          "created_on" timestamptz,
                                                          "created_by" int4,
                                                          "values_yaml_raw" text,
                                                          "status" varchar(100),
                                                          "updated_on" timestamptz,
                                                          "updated_by" int4,
                                                          "git_hash" varchar(255),
                                                          CONSTRAINT "installed_app_version_history_installed_app_version_id_fkey" FOREIGN KEY ("installed_app_version_id") REFERENCES "public"."installed_app_versions"("id"),
                                                          PRIMARY KEY ("id")
);


CREATE INDEX "version_history_git_hash_index" ON "public"."installed_app_version_history" USING BTREE ("git_hash");CREATE SEQUENCE IF NOT EXISTS "public"."id_seq_sso_login_config";

CREATE TABLE "public"."sso_login_config"
  (
     "id"         INT4 NOT NULL DEFAULT NEXTVAL('id_seq_sso_login_config'::
     regclass),
     "name"       VARCHAR(250),
     "label"      VARCHAR(250),
     "url"        VARCHAR(250),
     "config"     TEXT,
     "created_on" TIMESTAMPTZ,
     "created_by" INT4,
     "updated_on" TIMESTAMPTZ,
     "updated_by" INT4,
     "active"     BOOL,
     PRIMARY KEY ("id")
  );UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by", "name") VALUES
('cronjob-chart_1-3-0', '1.3.0', 'f', 't', 'now()', 1, 'now()', 1, 'Cron Job & Job');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-11-0' AND "version" = '4.11.0';
UPDATE chart_ref SET name = replace(name, 'Cron Job & Job', 'CronJob & Job');DROP TABLE "public"."app_store_charts_history" CASCADE;-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_external_link;

-- Table Definition
CREATE TABLE "public"."external_link" (
                                          "id" int4 NOT NULL DEFAULT nextval('id_seq_external_link'::regclass),
                                          "external_link_monitoring_tool_id" int4 NOT NULL,
                                          "name" varchar(255) NOT NULL,
                                          "url" varchar(255),
                                          "active" bool NOT NULL,
                                          "created_on" timestamptz,
                                          "created_by" int4,
                                          "updated_on" timestamptz,
                                          "updated_by" int4,
                                          PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_external_link_cluster_mapping;

-- Table Definition
CREATE TABLE "public"."external_link_cluster_mapping" (
                                                          "id" int4 NOT NULL DEFAULT nextval('id_seq_external_link_cluster_mapping'::regclass),
                                                          "external_link_id" int4 NOT NULL,
                                                          "cluster_id" int4 NOT NULL,
                                                          "active" bool NOT NULL,
                                                          "created_on" timestamptz,
                                                          "created_by" int4,
                                                          "updated_on" timestamptz,
                                                          "updated_by" int4,
                                                          PRIMARY KEY ("id")
);

-- This script only contains the table creation statements and does not fully represent the table in the database. It's still missing: indices, triggers. Do not use it as a backup.

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_external_link_monitoring_tool;

-- Table Definition
CREATE TABLE "public"."external_link_monitoring_tool" (
                                                          "id" int4 NOT NULL DEFAULT nextval('id_seq_external_link_monitoring_tool'::regclass),
                                                          "name" varchar(255) NOT NULL,
                                                          "icon" varchar(255),
                                                          "active" bool NOT NULL,
                                                          "created_on" timestamptz,
                                                          "created_by" int4,
                                                          "updated_on" timestamptz,
                                                          "updated_by" int4,
                                                          PRIMARY KEY ("id")
);

ALTER TABLE "public"."external_link" ADD FOREIGN KEY ("external_link_monitoring_tool_id") REFERENCES "public"."external_link_monitoring_tool"("id");
ALTER TABLE "public"."external_link_cluster_mapping" ADD FOREIGN KEY ("cluster_id") REFERENCES "public"."cluster"("id");
ALTER TABLE "public"."external_link_cluster_mapping" ADD FOREIGN KEY ("external_link_id") REFERENCES "public"."external_link"("id");


INSERT INTO "public"."external_link_monitoring_tool" ("name", "icon", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('Grafana', '', 't', 'now()', 1, 'now()', 1),
('Kibana', '', 't', 'now()', 1, 'now()', 1),
('Newrelic', '', 't', 'now()', 1, 'now()', 1),
('Coralogix', '', 't', 'now()', 1, 'now()', 1),
('Datadog', '', 't', 'now()', 1, 'now()', 1),
('Loki', '', 't', 'now()', 1, 'now()', 1),
('Cloudwatch', '', 't', 'now()', 1, 'now()', 1),
('Other', '', 't', 'now()', 1, 'now()', 1);UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_4-12-0', '4.12.0', 't', 't', 'now()', 1, 'now()', 1);
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by", "name") VALUES
('workflow-chart_1-0-0', '1.0.0', 'f', 'f', 'now()', 1, 'now()', 1, 'workflow-chart');
UPDATE git_provider
SET git_host_id=1
WHERE id = 1
  and git_host_id IS NULL;-- Sequence and defined type
CREATE SEQUENCE id_seq_module;

-- Table Definition
CREATE TABLE "public"."module"
(
    "id"         int4         NOT NULL DEFAULT nextval('id_seq_module'::regclass),
    "name"       varchar(255) NOT NULL,
    "version"    varchar(255) NOT NULL,
    "status"     varchar(255) NOT NULL,
    "updated_on" timestamptz,
    PRIMARY KEY ("id"),
    UNIQUE("name")
);

-- Sequence and defined type
CREATE SEQUENCE id_seq_module_action_audit_log;

-- Table Definition
CREATE TABLE "public"."module_action_audit_log"
(
    "id"          int4         NOT NULL DEFAULT nextval('id_seq_module_action_audit_log'::regclass),
    "module_name" varchar(255) NOT NULL,
    "version"     varchar(255) NOT NULL,
    "action"      varchar(255) NOT NULL,
    "created_on"  timestamptz  NOT NULL,
    "created_by"  int4         NOT NULL,
    PRIMARY KEY ("id")
);

-- Sequence and defined type
CREATE SEQUENCE id_seq_server_action_audit_log;

-- Table Definition
CREATE TABLE "public"."server_action_audit_log"
(
    "id"         int4         NOT NULL DEFAULT nextval('id_seq_server_action_audit_log'::regclass),
    "action"     varchar(255) NOT NULL,
    "version"    varchar(255),
    "created_on" timestamptz  NOT NULL,
    "created_by" int4         NOT NULL,
    PRIMARY KEY ("id")
);ALTER TABLE gitops_config
    ADD COLUMN email_id text;CREATE TABLE IF NOT EXISTS "public"."self_registration_roles" (
     "role" varchar(255) NOT NULL,
     "created_on" timestamptz,
     "created_by" int4,
     "updated_on" timestamptz,
     "updated_by" int4
);CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_metadata;

-- Table Definition
CREATE TABLE "public"."plugin_metadata"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_plugin_metadata'::regclass),
    "name"                        text,
    "description"                 text,
    "type"                        varchar(255),  -- SHARED, PRESET etc
    "icon"                        text,
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_tag;

-- Table Definition
CREATE TABLE "public"."plugin_tag"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_plugin_tag'::regclass),
    "name"                        varchar(255),
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_tag_relation;

-- Table Definition
CREATE TABLE "public"."plugin_tag_relation"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_plugin_tag_relation'::regclass),
    "tag_id"                      integer,
    "plugin_id"                   integer,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "plugin_tag_relation_tag_id_fkey" FOREIGN KEY ("tag_id") REFERENCES "public"."plugin_tag" ("id"),
    CONSTRAINT "plugin_tag_relation_plugin_id_fkey" FOREIGN KEY ("plugin_id") REFERENCES "public"."plugin_metadata" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_pipeline_script;

-- Table Definition
CREATE TABLE "public"."plugin_pipeline_script"
(
    "id"                           integer NOT NULL DEFAULT nextval('id_seq_plugin_pipeline_script'::regclass),
    "script"                       text,
    "type"                         varchar(255),   -- SHELL, DOCKERFILE, CONTAINER_IMAGE etc
    "store_script_at"              text,
    "dockerfile_exists"            bool,
    "mount_path"                   text,
    "mount_code_to_container"      bool,
    "mount_code_to_container_path" text,
    "mount_directory_from_host"    bool,
    "container_image_path"         text,
    "image_pull_secret_type"       varchar(255),   -- CONTAINER_REGISTRY or SECRET_PATH
    "image_pull_secret"            text,
    "deleted"                      bool,
    "created_on"                   timestamptz,
    "created_by"                   int4,
    "updated_on"                   timestamptz,
    "updated_by"                   int4,
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_script_path_arg_port_mapping;

-- Table Definition
CREATE TABLE "public"."script_path_arg_port_mapping"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_script_path_arg_port_mapping'::regclass),
    "type_of_mapping"             varchar(255),      -- FILE_PATH, DOCKER_ARG, PORT
    "file_path_on_disk"           text,
    "file_path_on_container"      text,
    "command"                     text,
    "args"                        text[],
    "port_on_local"               integer,
    "port_on_container"           integer,
    "script_id"                   integer,
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "script_path_arg_port_mapping_script_id_fkey" FOREIGN KEY ("script_id") REFERENCES "public"."plugin_pipeline_script" ("id"),
    PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_step;

-- Table Definition
CREATE TABLE "public"."plugin_step"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_plugin_step'::regclass),
    "plugin_id"                   integer,        -- id of plugin - parent of this step
    "name"                        varchar(255),
    "description"                 text,
    "index"                       integer,
    "step_type"                   varchar(255),   -- INLINE or REF_PLUGIN
    "script_id"                   integer,
    "ref_plugin_id"               integer,        -- id of plugin used as reference
    "output_directory_path"       text[],
    "dependent_on_step"           text,           -- name of step this step is dependent on
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "plugin_step_plugin_id_fkey" FOREIGN KEY ("plugin_id") REFERENCES "public"."plugin_metadata" ("id"),
    CONSTRAINT "plugin_step_script_id_fkey" FOREIGN KEY ("script_id") REFERENCES "public"."plugin_pipeline_script" ("id"),
    CONSTRAINT "plugin_step_ref_plugin_id_fkey" FOREIGN KEY ("ref_plugin_id") REFERENCES "public"."plugin_metadata" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_step_variable;

-- Table Definition
CREATE TABLE "public"."plugin_step_variable"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_plugin_step_variable'::regclass),
    "plugin_step_id"                integer,
    "name"                          varchar(255),
    "format"                        varchar(255),
    "description"                   text,
    "is_exposed"                    bool,
    "allow_empty_value"             bool,
    "default_value"                 varchar(255),
    "value"                         varchar(255),
    "variable_type"                 varchar(255),   -- INPUT or OUTPUT
    "value_type"                    varchar(255),   -- NEW, FROM_PREVIOUS_STEP or GLOBAL
    "previous_step_index"           integer,
    "variable_step_index"           integer,
    "variable_step_index_in_plugin" integer,        -- will contain step index of variable in case of ref plugin
    "reference_variable_name"       text,
    "deleted"                       bool,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "plugin_step_variable_plugin_step_id_fkey" FOREIGN KEY ("plugin_step_id") REFERENCES "public"."plugin_step" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_plugin_step_condition;

-- Table Definition
CREATE TABLE "public"."plugin_step_condition"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_plugin_step_condition'::regclass),
    "plugin_step_id"              integer,
    "condition_variable_id"       integer,      -- id of variable on which condition is written
    "condition_type"              varchar(255), -- SKIP, TRIGGER, SUCCESS or FAILURE
    "conditional_operator"        varchar(255),
    "conditional_value"           varchar(255),
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "plugin_step_condition_plugin_step_id_fkey" FOREIGN KEY ("plugin_step_id") REFERENCES "public"."plugin_step" ("id"),
    CONSTRAINT "plugin_step_condition_condition_variable_id_fkey" FOREIGN KEY ("condition_variable_id") REFERENCES "public"."plugin_step_variable" ("id"),
    PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_stage;

-- Table Definition
CREATE TABLE "public"."pipeline_stage"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_pipeline_stage'::regclass),
    "name"                        text,
    "description"                 text,
    "type"                        varchar(255),  -- PRE_CI, POST_CI, PRE_CD, POST_CD etc
    "deleted"                     bool,
    "ci_pipeline_id"              integer,
    "cd_pipeline_id"              integer,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "pipeline_stage_ci_pipeline_id_fkey" FOREIGN KEY ("ci_pipeline_id") REFERENCES "public"."ci_pipeline" ("id"),
    CONSTRAINT "pipeline_stage_cd_pipeline_id_fkey" FOREIGN KEY ("cd_pipeline_id") REFERENCES "public"."pipeline" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_stage_step;

-- Table Definition
CREATE TABLE "public"."pipeline_stage_step"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_pipeline_stage_step'::regclass),
    "pipeline_stage_id"           integer,
    "name"                        varchar(255),
    "description"                 text,
    "index"                       integer,
    "step_type"                   varchar(255),   -- INLINE or REF_PLUGIN
    "script_id"                   integer,
    "ref_plugin_id"               integer,        -- id of plugin used as reference
    "output_directory_path"       text[],
    "dependent_on_step"           text,           -- name of step this step is dependent on
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "pipeline_stage_step_script_id_fkey" FOREIGN KEY ("script_id") REFERENCES "public"."plugin_pipeline_script" ("id"),
    CONSTRAINT "pipeline_stage_step_ref_plugin_id_fkey" FOREIGN KEY ("ref_plugin_id") REFERENCES "public"."plugin_metadata" ("id"),
    PRIMARY KEY ("id")
);

CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_stage_step_variable;

-- Table Definition
CREATE TABLE "public"."pipeline_stage_step_variable"
(
    "id"                            integer NOT NULL DEFAULT nextval('id_seq_pipeline_stage_step_variable'::regclass),
    "pipeline_stage_step_id"        integer,
    "name"                          varchar(255),
    "format"                        varchar(255),
    "description"                   text,
    "is_exposed"                    bool,
    "allow_empty_value"             bool,
    "default_value"                 varchar(255),
    "value"                         varchar(255),
    "variable_type"                 varchar(255),   -- INPUT or OUTPUT
    "index"                         integer,
    "value_type"                    varchar(255),   -- NEW, FROM_PREVIOUS_STEP or GLOBAL
    "previous_step_index"           integer,
    "variable_step_index_in_plugin" integer,
    "reference_variable_name"       text,
    "reference_variable_stage"      text,
    "deleted"                       bool,
    "created_on"                    timestamptz,
    "created_by"                    int4,
    "updated_on"                    timestamptz,
    "updated_by"                    int4,
    CONSTRAINT "pipeline_stage_step_variable_pipeline_stage_step_id_fkey" FOREIGN KEY ("pipeline_stage_step_id") REFERENCES "public"."pipeline_stage_step" ("id"),
    PRIMARY KEY ("id")
);


CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_stage_step_condition;

-- Table Definition
CREATE TABLE "public"."pipeline_stage_step_condition"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_pipeline_stage_step_condition'::regclass),
    "pipeline_stage_step_id"      integer,
    "condition_variable_id"       integer,      -- id of variable on which condition is written
    "condition_type"              varchar(255), -- SKIP, TRIGGER, SUCCESS or FAILURE
    "conditional_operator"        varchar(255),
    "conditional_value"           varchar(255),
    "deleted"                     bool,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "pipeline_stage_step_condition_plugin_step_id_fkey" FOREIGN KEY ("pipeline_stage_step_id") REFERENCES "public"."pipeline_stage_step" ("id"),
    CONSTRAINT "pipeline_stage_step_condition_condition_variable_id_fkey" FOREIGN KEY ("condition_variable_id") REFERENCES "public"."pipeline_stage_step_variable" ("id"),
    PRIMARY KEY ("id")
);

----------- inserting values for PRESET plugins


INSERT INTO "public"."plugin_tag" ("id", "name", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'Load testing','f', 'now()', '1', 'now()', '1'),
('2', 'Code quality','f', 'now()', '1', 'now()', '1'),
('3', 'Security','f', 'now()', '1', 'now()', '1');

SELECT pg_catalog.setval('public.id_seq_plugin_tag', 3, true);

INSERT INTO "public"."plugin_metadata" ("id", "name", "description","type","icon","deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'K6 Load testing','K6 is an open-source tool and cloud service that makes load testing easy for developers and QA engineers.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/k6-plugin-icon.png','f', 'now()', '1', 'now()', '1'),
('2', 'Sonarqube','Enhance Your Workflow with Continuous Code Quality & Code Security.','PRESET','https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/sonarqube-plugin-icon.png','f', 'now()', '1', 'now()', '1');

SELECT pg_catalog.setval('public.id_seq_plugin_metadata', 2, true);

INSERT INTO "public"."plugin_tag_relation" ("id", "tag_id", "plugin_id", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', '1','1','now()', '1', 'now()', '1'),
('2', '2','2', 'now()', '1', 'now()', '1'),
('3', '3','2', 'now()', '1', 'now()', '1');

SELECT pg_catalog.setval('public.id_seq_plugin_tag_relation', 3, true);


INSERT INTO "public"."plugin_pipeline_script" ("id", "script", "type","deleted","created_on", "created_by", "updated_on", "updated_by") VALUES
('1', 'PathToScript=/devtroncd$RelativePathToScript

if [ $OutputType == "PROMETHEUS" ]
then
    wget https://go.dev/dl/go1.18.1.linux-amd64.tar.gz
    rm -rf /usr/local/go && tar -C /usr/local -xzf go1.18.1.linux-amd64.tar.gz
    export GOPATH=/usr/local/go
    export GOCACHE=/usr/local/go/cache
    export PATH=$PATH:/usr/local/go/bin
    go install go.k6.io/xk6/cmd/xk6@latest
    xk6 build --with github.com/grafana/xk6-output-prometheus-remote
    K6_PROMETHEUS_USER=$PrometheusUsername \
    K6_PROMETHEUS_PASSWORD=$PrometheusApiKey \
    K6_PROMETHEUS_REMOTE_URL=$PrometheusRemoteWriteEndpoint \
    ./k6 run $PathToScript -o output-prometheus-remote
elif [ $OutputType == "LOG" ]
then
    docker pull grafana/k6
	docker run --rm -i grafana/k6 run - <$PathToScript
else
    echo "OUTPUT_TYPE: $OutputType not supported"
fi','SHELL','f','now()', '1', 'now()', '1'),
('2', 'PathToCodeDir=/devtroncd$CheckoutPath

cd $PathToCodeDir
echo "sonar.projectKey=$SonarqubeProjectKey" > sonar-project.properties
docker run \
    --rm \
    -e SONAR_HOST_URL=$SonarqubeEndpoint \
    -e SONAR_LOGIN=$SonarqubeApiKey \
    -v "/$PWD:/usr/src" \
    sonarsource/sonar-scanner-cli','SHELL','f', 'now()', '1', 'now()', '1');

SELECT pg_catalog.setval('public.id_seq_plugin_pipeline_script', 2, true);

INSERT INTO "public"."plugin_step" ("id", "plugin_id","name","description","index","step_type","script_id","deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', '1','Step 1','Step 1 for K6 load testing','1','INLINE','1','f','now()', '1', 'now()', '1'),
('2', '2','Step 1','Step 1 for Sonarqube','1','INLINE','2','f','now()', '1', 'now()', '1');

SELECT pg_catalog.setval('public.id_seq_plugin_step', 2, true);


INSERT INTO "public"."plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed", "allow_empty_value", "variable_type", "value_type", "default_value", "variable_step_index", "deleted", "created_on", "created_by", "updated_on", "updated_by") VALUES
('1', '1','RelativePathToScript','STRING','checkout path + script path along with script name','t','f','INPUT','NEW','/./script.js','1','f','now()', '1', 'now()', '1'),
('2', '1','PrometheusUsername','STRING','username of prometheus account','t','t','INPUT','NEW',null, '1' ,'f','now()', '1', 'now()', '1'),
('3', '1','PrometheusApiKey','STRING','api key of prometheus account','t','t','INPUT','NEW',null, '1','f','now()', '1', 'now()', '1'),
('4', '1','PrometheusRemoteWriteEndpoint','STRING','remote write endpoint of prometheus account','t','t','INPUT','NEW',null, '1','f','now()', '1', 'now()', '1'),
('5', '1','OutputType','STRING','output type - LOG or PROMETHEUS','t','f','INPUT','NEW','LOG', '1','f','now()', '1', 'now()', '1'),
('6', '2','SonarqubeProjectKey','STRING','project key of grafana sonarqube account','t','t','INPUT','NEW',null, '1', 'f','now()', '1', 'now()', '1'),
('7', '2','SonarqubeApiKey','STRING','api key of sonarqube account','t','t','INPUT','NEW',null, '1', 'f','now()', '1', 'now()', '1'),
('8', '2','SonarqubeEndpoint','STRING','api endpoint of sonarqube account','t','t','INPUT','NEW',null, '1','f','now()', '1', 'now()', '1'),
('9', '2','CheckoutPath','STRING','checkout path of git material','t','t','INPUT','NEW',null, '1','f','now()', '1', 'now()', '1');

SELECT pg_catalog.setval('public.id_seq_plugin_step_variable', 9, true);
ALTER TABLE "public"."chart_repo" ADD COLUMN "user_name" varchar(250);
ALTER TABLE "public"."chart_repo" ADD COLUMN "password" varchar(250);
ALTER TABLE "public"."chart_repo" ADD COLUMN "ssh_key" varchar(250);
ALTER TABLE "public"."chart_repo" ADD COLUMN "access_token" varchar(250);
ALTER TABLE "public"."chart_repo" ADD COLUMN "auth_mode" varchar(250);ALTER TABLE pipeline_strategy_history
    ADD COLUMN pipeline_trigger_type varchar(255);ALTER TABLE "public"."external_link" ALTER COLUMN "url" SET DATA TYPE text;ALTER TABLE "public"."charts" ALTER COLUMN "git_repo_url" DROP NOT NULL;

ALTER TABLE "public"."charts" ALTER COLUMN "chart_location" DROP NOT NULL;

ALTER TABLE "public"."pipeline" ADD COLUMN "deployment_app_created" bool NOT NULL DEFAULT 'false';

update pipeline set deployment_app_created=true where deleted=false;ALTER TABLE chart_ref
    ADD COLUMN chart_description text DEFAULT '',
    ADD COLUMN user_uploaded boolean DEFAULT false ;
INSERT INTO "public"."plugin_tag" ("id", "name", "deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_tag'), 'DevSecOps', 'f', 'now()', '1', 'now()', '1');


--- dTrack plugin for python

INSERT INTO "public"."plugin_metadata" ("id", "name", "description", "type", "icon", "deleted", "created_on",
                                        "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_metadata'), 'Dependency track for Python',
        'Creates a bill of materials from Python projects and environments and uploads it to D-track for Component Analysis, to identify and reduce risk in the software supply chain.',
        'PRESET',
        'https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/dTrack-plugin-icon.png', 'f', 'now()', '1',
        'now()', '1');


INSERT INTO "public"."plugin_tag_relation" ("id", "tag_id", "plugin_id", "created_on", "created_by", "updated_on",
                                            "updated_by")
VALUES (nextval('id_seq_plugin_tag_relation'), 3,
        (select currval('id_seq_plugin_metadata')), 'now()', '1', 'now()', '1'),
       (nextval('id_seq_plugin_tag_relation'), (select currval('id_seq_plugin_tag')),
        (select currval('id_seq_plugin_metadata')), 'now()', '1', 'now()', '1');



INSERT INTO "public"."plugin_pipeline_script" ("id", "script", "type", "deleted", "created_on", "created_by",
                                               "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_pipeline_script'), 'apk add py3-pip
pip install cyclonedx-bom
mkdir $HOME/outDTrack
OutDirDTrack=$HOME/outDTrack
cd /devtroncd/$CheckoutPath
ToUploadBom=YES
if [ $ProjectManifestType == "POETRY" ]
then
	cyclonedx-bom -i $RelativePathToPoetryLock -o $OutDirDTrack/bom.json --format json -p
elif [ $ProjectManifestType == "PIP" ]
then
	cyclonedx-bom -i $RelativePathToPipfile -o $OutDirDTrack/bom.json --format json -pip
elif [ $ProjectManifestType == "REQUIREMENT" ]
then
	cyclonedx-bom -i $RelativePathToRequirementTxt -o $OutDirDTrack/bom.json --format json -r
elif [ $ProjectManifestType == "ENV" ]
then
	cyclonedx-bom -o $OutDirDTrack/bom.json --format json -e
else
    echo "MANIFEST_TYPE: $ProjectManifestType not supported"
    ToUploadBom=NO
fi

if [ $ToUploadBom == "YES" ]
then
	apk add curl
    cd $OutDirDTrack
	curl -v --location --request POST "$DTrackEndpoint/api/v1/bom" \
   		--header ''accept: application/json'' \
    	--header "X-Api-Key: $DTrackApiKey" \
    	--form "projectName=$DTrackProjectName" \
    	--form ''autoCreate="true"'' \
    	--form "projectVersion=$DTrackProjectVersion" \
    	--form ''bom=@"bom.json"''
fi', 'SHELL', 'f', 'now()', '1', 'now()', '1');


INSERT INTO "public"."plugin_step" ("id", "plugin_id", "name", "description", "index", "step_type", "script_id",
                                    "deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES ((nextval('id_seq_plugin_step')), (select currval('id_seq_plugin_metadata')), 'Step 1',
        'Step 1 - Dependency Track for Python)', '1', 'INLINE', (select currval('id_seq_plugin_pipeline_script')), 'f',
        'now()', '1', 'now()', '1');


INSERT INTO "public"."plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed",
                                             "allow_empty_value", "variable_type", "value_type", "default_value",
                                             "variable_step_index", "deleted", "created_on", "created_by", "updated_on",
                                             "updated_by")
VALUES ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'ProjectManifestType',
        'STRING',
        'type of your python project manifest which is to be used to build cycloneDx SBOM. OneOf - PIP, POETRY, ENV, REQUIREMENT',
        't', 'f',
        'INPUT', 'NEW', 'ENV', '1', 'f', 'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')),
        'RelativePathToPoetryLock',
        'STRING', 'Path to your poetry.lock file inside your project.', 't', 't', 'INPUT', 'NEW', 'poetry.lock', '1',
        'f', 'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')),
        'RelativePathToPipfile',
        'STRING', 'Path to your Pipfile.lock file inside your project.', 't', 't', 'INPUT', 'NEW', 'Pipfile.lock', '1',
        'f', 'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')),
        'RelativePathToRequirementTxt',
        'STRING', 'Path to your requirements.txt file inside your project.', 't', 't', 'INPUT', 'NEW',
        'requirements.txt', '1',
        'f', 'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackEndpoint',
        'STRING', 'Api endpoint of your dependency track account.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackProjectName',
        'STRING', 'Name of dependency track project.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackProjectVersion',
        'STRING', 'Version of dependency track project.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackApiKey',
        'STRING', 'Api key of your dependency track account.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'CheckoutPath',
        'STRING', 'Checkout path of git material.', 't', 'f', 'INPUT', 'NEW', './', '1', 'f',
        'now()', '1', 'now()', '1');


--- dTrack plugin for node.js

INSERT INTO "public"."plugin_metadata" ("id", "name", "description", "type", "icon", "deleted", "created_on",
                                        "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_metadata'), 'Dependency track for NodeJs',
        'Creates a bill of materials from NodeJs projects and environments and uploads it to D-track for Component Analysis, to identify and reduce risk in the software supply chain.',
        'PRESET',
        'https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/dTrack-plugin-icon.png', 'f', 'now()', '1',
        'now()', '1');


INSERT INTO "public"."plugin_tag_relation" ("id", "tag_id", "plugin_id", "created_on", "created_by", "updated_on",
                                            "updated_by")
VALUES (nextval('id_seq_plugin_tag_relation'), 3,
        (select currval('id_seq_plugin_metadata')), 'now()', '1', 'now()', '1'),
       (nextval('id_seq_plugin_tag_relation'), (select currval('id_seq_plugin_tag')),
        (select currval('id_seq_plugin_metadata')), 'now()', '1', 'now()', '1');



INSERT INTO "public"."plugin_pipeline_script" ("id", "script", "type", "deleted", "created_on", "created_by",
                                               "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_pipeline_script'), 'apk add npm
npm install -g @cyclonedx/bom
mkdir $HOME/outDTrack
OutDirDTrack=$HOME/outDTrack
cd /devtroncd/$CheckoutPath
npm install
cyclonedx-node -o $OutDirDTrack/bom.json
apk add curl
cd $OutDirDTrack
curl -v --location --request POST "$DTrackEndpoint/api/v1/bom" \
	--header ''accept: application/json'' \
	--header "X-Api-Key: $DTrackApiKey" \
	--form "projectName=$DTrackProjectName" \
	--form ''autoCreate="true"'' \
	--form "projectVersion=$DTrackProjectVersion" \
	--form ''bom=@"bom.json"''', 'SHELL', 'f', 'now()', '1', 'now()', '1');


INSERT INTO "public"."plugin_step" ("id", "plugin_id", "name", "description", "index", "step_type", "script_id",
                                    "deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES ((nextval('id_seq_plugin_step')), (select currval('id_seq_plugin_metadata')), 'Step 1',
        'Step 1 - Dependency Track for NodeJs', '1', 'INLINE', (select currval('id_seq_plugin_pipeline_script')), 'f',
        'now()', '1', 'now()', '1');


INSERT INTO "public"."plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed",
                                             "allow_empty_value", "variable_type", "value_type", "default_value",
                                             "variable_step_index", "deleted", "created_on", "created_by", "updated_on",
                                             "updated_by")
VALUES ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackEndpoint',
        'STRING', 'Api endpoint of your dependency track account.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackProjectName',
        'STRING', 'Name of dependency track project.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackProjectVersion',
        'STRING', 'Version of dependency track project.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackApiKey',
        'STRING', 'Api key of your dependency track account.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'CheckoutPath',
        'STRING', 'Checkout path of git material.', 't', 'f', 'INPUT', 'NEW', './', '1', 'f',
        'now()', '1', 'now()', '1');


--- dTrack plugin for maven & gradle

INSERT INTO "public"."plugin_metadata" ("id", "name", "description", "type", "icon", "deleted", "created_on",
                                        "created_by", "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_metadata'), 'Dependency track for Maven & Gradle',
        'Creates a bill of materials from Maven/Gradle projects and environments and uploads it to D-track for Component Analysis, to identify and reduce risk in the software supply chain.',
        'PRESET',
        'https://raw.githubusercontent.com/devtron-labs/devtron/main/assets/dTrack-plugin-icon.png', 'f', 'now()', '1',
        'now()', '1');


INSERT INTO "public"."plugin_tag_relation" ("id", "tag_id", "plugin_id", "created_on", "created_by", "updated_on",
                                            "updated_by")
VALUES (nextval('id_seq_plugin_tag_relation'), 3,
        (select currval('id_seq_plugin_metadata')), 'now()', '1', 'now()', '1'),
       (nextval('id_seq_plugin_tag_relation'), (select currval('id_seq_plugin_tag')),
        (select currval('id_seq_plugin_metadata')), 'now()', '1', 'now()', '1');



INSERT INTO "public"."plugin_pipeline_script" ("id", "script", "type", "deleted", "created_on", "created_by",
                                               "updated_on", "updated_by")
VALUES (nextval('id_seq_plugin_pipeline_script'), 'mkdir $HOME/outDTrack
OutDirDTrack=$HOME/outDTrack
cd /devtroncd/$CheckoutPath
ToUploadBom=YES
if [ $BuildToolType == "GRADLE" ]
then
	apk add gradle
	gradle cyclonedxBom
	cp build/reports/bom.json $OutDirDTrack/bom.json
elif [ $BuildToolType == "MAVEN" ]
then
	apk add maven
	mvn install
	cp target/bom.json $OutDirDTrack/bom.json
else
    echo "BUILD_TYPE: $BuildToolType not supported"
    ToUploadBom=NO
fi

if [ $ToUploadBom == "YES" ]
then
	apk add curl
    cd $OutDirDTrack
	curl -v --location --request POST "$DTrackEndpoint/api/v1/bom" \
   		--header ''accept: application/json'' \
    	--header "X-Api-Key: $DTrackApiKey" \
    	--form "projectName=$DTrackProjectName" \
    	--form ''autoCreate="true"'' \
    	--form "projectVersion=$DTrackProjectVersion" \
    	--form ''bom=@"bom.json"''
fi', 'SHELL', 'f', 'now()', '1', 'now()', '1');


INSERT INTO "public"."plugin_step" ("id", "plugin_id", "name", "description", "index", "step_type", "script_id",
                                    "deleted", "created_on", "created_by", "updated_on", "updated_by")
VALUES ((nextval('id_seq_plugin_step')), (select currval('id_seq_plugin_metadata')), 'Step 1',
        'Step 1 for Dependency Track for Maven & Gradle', '1', 'INLINE',
        (select currval('id_seq_plugin_pipeline_script')),
        'f',
        'now()', '1', 'now()', '1');


INSERT INTO "public"."plugin_step_variable" ("id", "plugin_step_id", "name", "format", "description", "is_exposed",
                                             "allow_empty_value", "variable_type", "value_type", "default_value",
                                             "variable_step_index", "deleted", "created_on", "created_by", "updated_on",
                                             "updated_by")
VALUES ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'BuildToolType',
        'STRING', 'Type of build tool your project is using. OneOf - MAVEN, GRADLE.', 't', 'f', 'INPUT', 'NEW', NULL,
        '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackEndpoint',
        'STRING', 'Api endpoint of your dependency track account.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackProjectName',
        'STRING', 'Name of dependency track project.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackProjectVersion',
        'STRING', 'Version of dependency track project.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'DTrackApiKey',
        'STRING', 'Api key of your dependency track account.', 't', 'f', 'INPUT', 'NEW', NULL, '1', 'f',
        'now()', '1', 'now()', '1'),
       ((nextval('id_seq_plugin_step_variable')), (select currval('id_seq_plugin_metadata')), 'CheckoutPath',
        'STRING', 'Checkout path of git material.', 't', 'f', 'INPUT', 'NEW', './', '1', 'f',
        'now()', '1', 'now()', '1');-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_api_token;

-- Table Definition
CREATE TABLE "public"."api_token"
(
    "id"              int4        NOT NULL DEFAULT nextval('id_seq_api_token'::regclass),
    "user_id"         int4        NOT NULL,
    "name"            varchar(50) NOT NULL UNIQUE,
    "description"     text        NOT NULL,
    "expire_at_in_ms" bigint, -- null means never
    "token"           text        NOT NULL UNIQUE,
    "created_on"      timestamptz NOT NULL,
    "created_by"      int4,
    "updated_on"      timestamptz,
    "updated_by"      int4,
    PRIMARY KEY ("id")
);

-- add foreign key
ALTER TABLE "public"."api_token" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users"("id");

-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_user_audit;

-- Table Definition
CREATE TABLE "public"."user_audit"
(
    "id"         int4         NOT NULL DEFAULT nextval('id_seq_user_audit'::regclass),
    "user_id"    int4         NOT NULL,
    "client_ip"  varchar(256) NOT NULL,
    "created_on" timestamptz  NOT NULL,
    PRIMARY KEY ("id")
);

-- add foreign key
ALTER TABLE "public"."user_audit" ADD FOREIGN KEY ("user_id") REFERENCES "public"."users" ("id");

--- Create index on user_audit.user_id
CREATE INDEX user_audit_user_id_IX ON public.user_audit (user_id);

-- insert secret into attributes table
INSERT INTO attributes(key, value, active, created_on, created_by)
VALUES ('apiTokenSecret', MD5(random()::text), 't', NOW(), 1);

-- add column user_type in user table
ALTER TABLE users ADD COLUMN user_type varchar(250);ALTER TABLE "public"."pipeline" ADD COLUMN "deployment_app_type" varchar(50);
ALTER TABLE "public"."charts" ADD COLUMN "reference_chart" bytea;
UPDATE "public"."pipeline" SET "deployment_app_type" = 'argo_cd';ALTER TABLE "public"."installed_apps" ADD COLUMN "deployment_app_type" varchar(50);

update installed_apps set deployment_app_type='helm' WHERE app_id in (SELECT id from app WHERE app_offering_mode='EA_ONLY');

update installed_apps set deployment_app_type='argo_cd' WHERE app_id in (SELECT id from app WHERE app_offering_mode!='EA_ONLY');ALTER TABLE cluster
    ADD COLUMN error_in_connecting TEXT;
UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_4-13-0', '4.13.0', 't', 't', 'now()', 1, 'now()', 1);
ALTER TABLE "public"."cluster" ADD COLUMN "agent_installation_stage" int4 DEFAULT 0;CREATE SEQUENCE IF NOT EXISTS id_seq_smtp_config;

CREATE TABLE public.smtp_config (
"id"                          integer NOT NULL DEFAULT nextval('id_seq_smtp_config'::regclass),
"port"                        text,
"host"                        text,
"auth_type"                   text,
"auth_user"                   text,
"auth_password"               text,
"from_email"                  text,
"config_name"                 text,
"description"                 text,
"owner_id"                    int4,
"default"                     bool,
"deleted"                     bool NOT NULL DEFAULT FALSE,
"created_on"                  timestamptz,
"created_by"                  int4,
"updated_on"                  timestamptz,
"updated_by"                  int4,
PRIMARY KEY ("id")
);ALTER TABLE ci_template
    ADD COLUMN target_platform VARCHAR(1000) NOT NULL DEFAULT '';
ALTER TABLE app_store_application_version ADD COLUMN values_schema_json TEXT;

ALTER TABLE app_store_application_version ADD COLUMN notes TEXT;ALTER TABLE app_store_version_values ADD COLUMN description TEXT;--- Create index on image_scan_execution_history_id in image_scan_execution_result
CREATE INDEX IF NOT EXISTS image_scan_execution_history_id_IX ON public.image_scan_execution_result (image_scan_execution_history_id);CREATE SEQUENCE IF NOT EXISTS id_seq_pipeline_status_timeline;

-- Table Definition
CREATE TABLE "public"."pipeline_status_timeline"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_pipeline_status_timeline'::regclass),
    "status"                      varchar(255),
    "status_detail"               text,
    "status_time"                 timestamptz,
    "cd_workflow_runner_id"       integer,
    "installed_app_version_history_id"   integer,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "pipeline_status_timeline_cd_workflow_runner_id_fkey" FOREIGN KEY ("cd_workflow_runner_id") REFERENCES "public"."cd_workflow_runner" ("id"),
    CONSTRAINT "pipeline_status_timeline_installed_app_version_history_id_fkey" FOREIGN KEY ("installed_app_version_history_id") REFERENCES "public"."installed_app_version_history" ("id"),
    PRIMARY KEY ("id")
);--- Create index on app_store_id in app_store_application_version
CREATE INDEX IF NOT EXISTS app_store_application_version_app_store_id_IX ON public.app_store_application_version USING btree(app_store_id);---- update notification template for CI trigger ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI triggered for app: {{appName}}",
 "html": "<h2 style=\"color:#767d84;\">Build Pipeline Triggered</h2><span>{{eventTime}}</span><br><span>Triggered by <strong>{{triggeredBy}}</strong></span><br><br>{{#buildHistoryLink}}<a href=\"{{& buildHistoryLink }}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#0066cc;color:#fff;border:1px solid transparent;cursor:pointer;\">View Pipeline</a><br><br>{{/buildHistoryLink}}<hr><br><span>Application: <strong>{{appName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Pipeline: <strong>{{pipelineName}}</strong></span><br><br><hr><h3>Source Code</h3>{{#ciMaterials}}{{^webhookType}}<span>Branch: <strong>{{appName}}/{{branch}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Commit: <a href=\"{{& commitLink }}\"><strong>{{commit}}</strong></a></span><br><br>{{/webhookType}}{{#webhookType}}{{#webhookData.mergedType}}<span>Title: <strong>{{webhookData.data.title}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Git URL: <a href=\"{{& webhookData.data.giturl}}\"><strong>View</strong></a></span><br><br><span>Source Branch: <strong>{{webhookData.data.sourcebranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Source Commit: <a href=\"{{& webhookData.data.sourcecheckoutlink}}\"><strong>{{webhookData.data.sourcecheckout}}</strong></a></span><br><br><span>Target Branch: <strong>{{webhookData.data.targetbranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Target Commit: <a href=\"{{& webhookData.data.targetcheckoutlink}}\"><strong>{{webhookData.data.targetcheckout}}</strong></a></span><br><br>{{/webhookData.mergedType}}{{^webhookData.mergedType}}<span>Target Checkout: <strong>{{webhookData.data.targetcheckout}}</strong></span><br>{{/webhookData.mergedType}}{{/webhookType}}{{/ciMaterials}}<br>"}'
where channel_type = 'ses'
and node_type = 'CI'
and event_type_id = 1;


---- update notification template for CI success ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI success for app: {{appName}}",
 "html": "<h2 style=\"color:#1dad70;\">Build Pipeline Successful</h2><span>{{eventTime}}</span><br><span>Triggered by <strong>{{triggeredBy}}</strong></span><br><br><a href=\"{{& buildHistoryLink }}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#0066cc;color:#fff;border:1px solid transparent;cursor:pointer;\">View Pipeline</a><br><br><hr><br><span>Application: <strong>{{appName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Pipeline: <strong>{{pipelineName}}</strong></span><br><br><hr><h3>Source Code</h3>{{#ciMaterials}}{{^webhookType}}<span>Branch: <strong>{{appName}}/{{branch}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Commit: <a href=\"{{& commitLink }}\"><strong>{{commit}}</strong></a></span><br><br>{{/webhookType}}{{#webhookType}}{{#webhookData.mergedType}}<span>Title: <strong>{{webhookData.data.title}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Git URL: <a href=\"{{& webhookData.data.giturl}}\"><strong>View</strong></a></span><br><br><span>Source Branch: <strong>{{webhookData.data.sourcebranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Source Commit: <a href=\"{{& webhookData.data.sourcecheckoutlink}}\"><strong>{{webhookData.data.sourcecheckout}}</strong></a></span><br><br><span>Target Branch: <strong>{{webhookData.data.targetbranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Target Commit: <a href=\"{{& webhookData.data.targetcheckoutlink}}\"><strong>{{webhookData.data.targetcheckout}}</strong></a></span><br><br>{{/webhookData.mergedType}}{{^webhookData.mergedType}}<span>Target Checkout: <strong>{{webhookData.data.targetcheckout}}</strong></span><br>{{/webhookData.mergedType}}{{/webhookType}}{{/ciMaterials}}<br>"}'
where channel_type = 'ses'
and node_type = 'CI'
and event_type_id = 2;



---- update notification template for CI fail ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI failed for app: {{appName}}",
 "html": "<h2 style=\"color:#f33e3e;\">Build Pipeline Failed</h2><span>{{eventTime}}</span><br><span>Triggered by <strong>{{triggeredBy}}</strong></span><br><br><a href=\"{{& buildHistoryLink }}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#0066cc;color:#fff;border:1px solid transparent;cursor:pointer;\">View Pipeline</a><br><br><hr><br><span>Application: <strong>{{appName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Pipeline: <strong>{{pipelineName}}</strong></span><br><br><hr><h3>Source Code</h3>{{#ciMaterials}}{{^webhookType}}<span>Branch: <strong>{{appName}}/{{branch}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Commit: <a href=\"{{& commitLink }}\"><strong>{{commit}}</strong></a></span><br><br>{{/webhookType}}{{#webhookType}}{{#webhookData.mergedType}}<span>Title: <strong>{{webhookData.data.title}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Git URL: <a href=\"{{& webhookData.data.giturl}}\"><strong>View</strong></a></span><br><br><span>Source Branch: <strong>{{webhookData.data.sourcebranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Source Commit: <a href=\"{{& webhookData.data.sourcecheckoutlink}}\"><strong>{{webhookData.data.sourcecheckout}}</strong></a></span><br><br><span>Target Branch: <strong>{{webhookData.data.targetbranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Target Commit: <a href=\"{{& webhookData.data.targetcheckoutlink}}\"><strong>{{webhookData.data.targetcheckout}}</strong></a></span><br><br>{{/webhookData.mergedType}}{{^webhookData.mergedType}}<span>Target Checkout: <strong>{{webhookData.data.targetcheckout}}</strong></span><br>{{/webhookData.mergedType}}{{/webhookType}}{{/ciMaterials}}<br>"}'
where channel_type = 'ses'
and node_type = 'CI'
and event_type_id = 3;


---- update notification template for CD trigger ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD triggered for app: {{appName}} on environment: {{envName}}",
 "html": "<h2 style=\"color:#767d84;\">{{stage}} Pipeline Triggered</h2><span>{{eventTime}}</span><br><span>Triggered by <strong>{{triggeredBy}}</strong></span><br><br>{{#deploymentHistoryLink}}<a href=\"{{& deploymentHistoryLink}}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#0066cc;color:#fff;border:1px solid transparent;cursor:pointer;\">View Pipeline</a>{{/deploymentHistoryLink}}&nbsp;&nbsp;&nbsp;{{#appDetailsLink}}<a href=\"{{& appDetailsLink}}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#fff;color:#3b444c;border:1px solid #d0d4d9;cursor:pointer;\">App Details</a><br><br>{{/appDetailsLink}}<hr><br><span>Application: <strong>{{appName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Pipeline: <strong>{{pipelineName}}</strong></span><br><br><span>Environment: <strong>{{envName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Stage: <strong>{{stage}}</strong></span><br><br><hr><h3>Source Code</h3>{{#ciMaterials}}{{^webhookType}}<span>Branch: <strong>{{appName}}/{{branch}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Commit: <a href=\"{{& commitLink}}\"><strong>{{commit}}</strong></a></span><br>{{/webhookType}}{{#webhookType}}{{#webhookData.mergedType}}<span>Title: <strong>{{webhookData.data.title}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Git URL: <a href=\"{{& webhookData.data.giturl}}\"><strong>View</strong></a></span><br><span>Source Branch: <strong>{{webhookData.data.sourcebranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Source Commit: <a href=\"{{& webhookData.data.sourcecheckoutlink}}\"><strong>{{webhookData.data.sourcecheckout}}</strong></a></span><br><span>Target Branch: <strong>{{webhookData.data.targetbranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Target Commit: <a href=\"{{& webhookData.data.targetcheckoutlink}}\"><strong>{{webhookData.data.targetcheckout}}</strong></a></span><br>{{/webhookData.mergedType}}{{^webhookData.mergedType}}<span>Target Checkout: <strong>{{webhookData.data.targetcheckout}}</strong></span><br>{{/webhookData.mergedType}}{{/webhookType}}{{/ciMaterials}}<br><br><hr><h3>Image</h3><span>Docker Image: <strong>{{dockerImg}}</strong></span><br>"}'
where channel_type = 'ses'
and node_type = 'CD'
and event_type_id = 1;



---- update notification template for CD success ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD success for app: {{appName}} on environment: {{envName}}",
 "html": "<h2 style=\"color:#1dad70;\">{{stage}} Pipeline Successful</h2><span>{{eventTime}}</span><br><span>Triggered by <strong>{{triggeredBy}}</strong></span><br><br>{{#deploymentHistoryLink}}<a href=\"{{& deploymentHistoryLink}}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#0066cc;color:#fff;border:1px solid transparent;cursor:pointer;\">View Pipeline</a>{{/deploymentHistoryLink}}&nbsp;&nbsp;&nbsp;{{#appDetailsLink}}<a href=\"{{& appDetailsLink}}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#fff;color:#3b444c;border:1px solid #d0d4d9;cursor:pointer;\">App Details</a><br><br>{{/appDetailsLink}}<hr><br><span>Application: <strong>{{appName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Pipeline: <strong>{{pipelineName}}</strong></span><br><br><span>Environment: <strong>{{envName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Stage: <strong>{{stage}}</strong></span><br><br><hr><h3>Source Code</h3>{{#ciMaterials}}{{^webhookType}}<span>Branch: <strong>{{appName}}/{{branch}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Commit: <a href=\"{{& commitLink}}\"><strong>{{commit}}</strong></a></span><br>{{/webhookType}}{{#webhookType}}{{#webhookData.mergedType}}<span>Title: <strong>{{webhookData.data.title}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Git URL: <a href=\"{{& webhookData.data.giturl}}\"><strong>View</strong></a></span><br><span>Source Branch: <strong>{{webhookData.data.sourcebranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Source Commit: <a href=\"{{& webhookData.data.sourcecheckoutlink}}\"><strong>{{webhookData.data.sourcecheckout}}</strong></a></span><br><span>Target Branch: <strong>{{webhookData.data.targetbranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Target Commit: <a href=\"{{& webhookData.data.targetcheckoutlink}}\"><strong>{{webhookData.data.targetcheckout}}</strong></a></span><br>{{/webhookData.mergedType}}{{^webhookData.mergedType}}<span>Target Checkout: <strong>{{webhookData.data.targetcheckout}}</strong></span><br>{{/webhookData.mergedType}}{{/webhookType}}{{/ciMaterials}}<br><br><hr><h3>Image</h3><span>Docker Image: <strong>{{dockerImg}}</strong></span><br>"}'
where channel_type = 'ses'
and node_type = 'CD'
and event_type_id = 2;


---- update notification template for CD fail ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD failed for app: {{appName}} on environment: {{envName}}",
 "html": "<h2 style=\"color:#f33e3e;\">{{stage}} Pipeline Failed</h2><span>{{eventTime}}</span><br><span>Triggered by <strong>{{triggeredBy}}</strong></span><br><br>{{#deploymentHistoryLink}}<a href=\"{{& deploymentHistoryLink}}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#0066cc;color:#fff;border:1px solid transparent;cursor:pointer;\">View Pipeline</a>{{/deploymentHistoryLink}}&nbsp;&nbsp;&nbsp;{{#appDetailsLink}}<a href=\"{{& appDetailsLink}}\" style=\"height:32px;padding:7px 12px;line-height:32px;font-size:12px;font-weight:600;border-radius:4px;text-decoration:none;outline:none;min-width:64px;text-transform:capitalize;text-align:center;background:#fff;color:#3b444c;border:1px solid #d0d4d9;cursor:pointer;\">App Details</a><br><br>{{/appDetailsLink}}<hr><br><span>Application: <strong>{{appName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Pipeline: <strong>{{pipelineName}}</strong></span><br><br><span>Environment: <strong>{{envName}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Stage: <strong>{{stage}}</strong></span><br><br><hr><h3>Source Code</h3>{{#ciMaterials}}{{^webhookType}}<span>Branch: <strong>{{appName}}/{{branch}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Commit: <a href=\"{{& commitLink}}\"><strong>{{commit}}</strong></a></span><br>{{/webhookType}}{{#webhookType}}{{#webhookData.mergedType}}<span>Title: <strong>{{webhookData.data.title}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Git URL: <a href=\"{{& webhookData.data.giturl}}\"><strong>View</strong></a></span><br><span>Source Branch: <strong>{{webhookData.data.sourcebranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Source Commit: <a href=\"{{& webhookData.data.sourcecheckoutlink}}\"><strong>{{webhookData.data.sourcecheckout}}</strong></a></span><br><span>Target Branch: <strong>{{webhookData.data.targetbranchname}}</strong></span>&nbsp;&nbsp;|&nbsp;&nbsp;<span>Target Commit: <a href=\"{{& webhookData.data.targetcheckoutlink}}\"><strong>{{webhookData.data.targetcheckout}}</strong></a></span><br>{{/webhookData.mergedType}}{{^webhookData.mergedType}}<span>Target Checkout: <strong>{{webhookData.data.targetcheckout}}</strong></span><br>{{/webhookData.mergedType}}{{/webhookType}}{{/ciMaterials}}<br><br><hr><h3>Image</h3><span>Docker Image: <strong>{{dockerImg}}</strong></span><br>"}'
where channel_type = 'ses'
and node_type = 'CD'
and event_type_id = 3;ALTER TABLE ci_pipeline_material
    ADD COLUMN regex varchar(50) DEFAULT '';UPDATE pipeline_status_timeline
SET status ='KUBECTL_APPLY_SYNCED'
WHERE status = 'KUBECTL APPLY SYNCED';

UPDATE pipeline_status_timeline
SET status ='KUBECTL_APPLY_STARTED'
WHERE status = 'KUBECTL APPLY STARTED';

UPDATE pipeline_status_timeline
SET status ='GIT_COMMIT'
WHERE status = 'GIT COMMIT';-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_gitops_config;

-- Table Definition
CREATE TABLE "public"."gitops_config" (
    "id" int4 NOT NULL DEFAULT nextval('id_seq_gitops_config'::regclass),
    "provider" varchar(250) NOT NULL,
    "username" varchar(250) NOT NULL,
    "token" varchar(250) NOT NULL,
    "github_org_id" varchar(250),
    "host" varchar(250) NOT NULL,
    "active" bool NOT NULL,
    "created_on" timestamptz,
    "created_by" integer,
    "updated_on" timestamptz,
    "updated_by" integer,
    "gitlab_group_id" varchar(250),
    PRIMARY KEY ("id")
);---- update notification template for CI trigger slack
UPDATE notification_templates
set template_payload = '{
    "text": ":arrow_forward: Build pipeline Triggered |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":arrow_forward: *Build Pipeline triggered*\n<!date^{{eventTime}}^{date_long} {time} | \"-\"> \n Triggered by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url": "https://github.com/devtron-labs/notifier/assets/image/img_build_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Pipeline*\n{{pipelineName}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "actions",
            "elements": [{
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "View Details"
                }
                {{#buildHistoryLink}}
                    ,
                    "url": "{{& buildHistoryLink}}"
                {{/buildHistoryLink}}
            }]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CI'
and event_type_id = 1;


---- update notification template for CI success slack
UPDATE notification_templates
set template_payload = '{
  "text": ":tada: Build pipeline Successful |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
  "blocks": [
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": "\n"
      }
    },
    {
      "type": "divider"
    },
    {
      "type": "section",
      "text": {
        "type": "mrkdwn",
        "text": ":tada: *Build Pipeline successful*\n<!date^{{eventTime}}^{date_long} {time} | \"-\"> \n Triggered by {{triggeredBy}}"
      },
      "accessory": {
        "type": "image",
        "image_url": "https://github.com/devtron-labs/notifier/assets/image/img_build_notification.png",
        "alt_text": "calendar thumbnail"
      }
    },
    {
      "type": "section",
      "fields": [
        {
          "type": "mrkdwn",
          "text": "*Application*\n{{appName}}"
        },
        {
          "type": "mrkdwn",
          "text": "*Pipeline*\n{{pipelineName}}"
        }
      ]
    },
    {{#ciMaterials}}
    {{^webhookType}}
    {
    "type": "section",
    "fields": [
        {
          "type": "mrkdwn",
           "text": "*Branch*\n`{{appName}}/{{branch}}`"
        },
        {
          "type": "mrkdwn",
          "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
        }
    ]
    },
    {{/webhookType}}
    {{#webhookType}}
    {{#webhookData.mergedType}}
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Title*\n{{webhookData.data.title}}"
        },
        {
        "type": "mrkdwn",
        "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
        }
    ]
    },
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
        },
        {
        "type": "mrkdwn",
        "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
        }
    ]
    },
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
        },
        {
        "type": "mrkdwn",
        "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
        }
    ]
    },
    {{/webhookData.mergedType}}
    {{^webhookData.mergedType}}
    {
    "type": "section",
    "fields": [
        {
        "type": "mrkdwn",
        "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
        }
    ]
    },
    {{/webhookData.mergedType}}
    {{/webhookType}}
    {{/ciMaterials}}
    {
      "type": "actions",
      "elements": [
        {
          "type": "button",
          "text": {
            "type": "plain_text",
            "text": "View Details"
          }
          {{#buildHistoryLink}}
            ,
            "url": "{{& buildHistoryLink}}"
          {{/buildHistoryLink}}
        }
      ]
    }
  ]
}'
where channel_type = 'slack'
and node_type = 'CI'
and event_type_id = 2;



---- update notification template for CI fail slack
UPDATE notification_templates
set template_payload = '{
    "text": ":x: Build pipeline Failed |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":x: *Build Pipeline failed*\n<!date^{{eventTime}}^{date_long} {time} | \"-\"> \n Triggered by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url": "https://github.com/devtron-labs/notifier/assets/image/img_build_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Pipeline*\n{{pipelineName}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "actions",
            "elements": [{
                "type": "button",
                "text": {
                    "type": "plain_text",
                    "text": "View Details"
                }
                  {{#buildHistoryLink}}
                    ,
                    "url": "{{& buildHistoryLink}}"
                   {{/buildHistoryLink}}
            }]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CI'
and event_type_id = 3;


---- update notification template for CD trigger slack
UPDATE notification_templates
set template_payload = '{
    "text": ":arrow_forward: Deployment pipeline Triggered |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":arrow_forward: *Deployment Pipeline triggered on {{envName}}*\n<!date^{{eventTime}}^{date_long} {time} | \"-\"> \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/notifier/assets/image/img_deployment_notification.png",
                "alt_text": "Deploy Pipeline Triggered"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
             "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CD'
and event_type_id = 1;



---- update notification template for CD success slack
UPDATE notification_templates
set template_payload = '{
    "text": ":tada: Deployment pipeline Successful |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":tada: *Deployment Pipeline successful on {{envName}}*\n<!date^{{eventTime}}^{date_long} {time} | \"-\"> \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/notifier/assets/image/img_deployment_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
             "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CD'
and event_type_id = 2;


---- update notification template for CD fail slack
UPDATE notification_templates
set template_payload = '{
    "text": ":x: Deployment pipeline Failed |  {{#ciMaterials}} Branch > {{branch}} {{/ciMaterials}} | Application > {{appName}}",
    "blocks": [{
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "\n"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": ":x: *Deployment Pipeline failed on {{envName}}*\n<!date^{{eventTime}}^{date_long} {time} | \"-\"> \n by {{triggeredBy}}"
            },
            "accessory": {
                "type": "image",
                "image_url":"https://github.com/devtron-labs/notifier/assets/image/img_deployment_notification.png",
                "alt_text": "calendar thumbnail"
            }
        },
        {
            "type": "divider"
        },
        {
            "type": "section",
            "fields": [{
                    "type": "mrkdwn",
                    "text": "*Application*\n{{appName}}\n*Pipeline*\n{{pipelineName}}"
                },
                {
                    "type": "mrkdwn",
                    "text": "*Environment*\n{{envName}}\n*Stage*\n{{stage}}"
                }
            ]
        },
        {{#ciMaterials}}
        {{^webhookType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Branch*\n`{{appName}}/{{branch}}`"
            },
            {
            "type": "mrkdwn",
            "text": "*Commit*\n<{{& commitLink}}|{{commit}}>"
            }
        ]
        },
        {{/webhookType}}
        {{#webhookType}}
        {{#webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Title*\n{{webhookData.data.title}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Git URL*\n<{{& webhookData.data.giturl}}|View>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Source Branch*\n{{webhookData.data.sourcebranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Source Commit*\n<{{& webhookData.data.sourcecheckoutlink}}|{{webhookData.data.sourcecheckout}}>"
            }
        ]
        },
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Branch*\n{{webhookData.data.targetbranchname}}"
            },
            {
            "type": "mrkdwn",
            "text": "*Target Commit*\n<{{& webhookData.data.targetcheckoutlink}}|{{webhookData.data.targetcheckout}}>"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{^webhookData.mergedType}}
        {
        "type": "section",
        "fields": [
            {
            "type": "mrkdwn",
            "text": "*Target Checkout*\n{{webhookData.data.targetcheckout}}"
            }
        ]
        },
        {{/webhookData.mergedType}}
        {{/webhookType}}
        {{/ciMaterials}}
        {
            "type": "section",
            "text": {
                "type": "mrkdwn",
                "text": "*Docker Image*\n`{{dockerImg}}`"
            }
        },
        {
            "type": "actions",
            "elements": [{
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "View Pipeline",
                        "emoji": true
                    }
                    {{#deploymentHistoryLink}}
                    ,
                    "url": "{{& deploymentHistoryLink}}"
                      {{/deploymentHistoryLink}}
                },
                {
                    "type": "button",
                    "text": {
                        "type": "plain_text",
                        "text": "App details",
                        "emoji": true
                    }
                    {{#appDetailsLink}}
                    ,
                    "url": "{{& appDetailsLink}}"
                      {{/appDetailsLink}}
                }
            ]
        }
    ]
}'
where channel_type = 'slack'
and node_type = 'CD'
and event_type_id = 3;UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
('reference-chart_4-14-0', '4.14.0', 't', 't', 'now()', 1, 'now()', 1);
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
    ('reference-chart_3-13-0', '3.13.0', 'f', 't', 'now()', 1, 'now()', 1);--
-- Name: user_attributes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE IF NOT EXISTS public.user_attributes (
                                                   email_id varchar(500) NOT NULL,
                                                   user_data json NOT NULL,
                                                   created_on timestamp with time zone,
                                                   updated_on timestamp with time zone,
                                                   created_by integer,
                                                   updated_by integer,
                                                   PRIMARY KEY ("email_id")
);


ALTER TABLE public.user_attributes OWNER TO postgres;INSERT INTO module(name, version, status, updated_on)
SELECT 'argo-cd', version, status, now()
FROM module
WHERE name = 'cicd' and status = 'installed' and not exists (SELECT 1 FROM module where name = 'argo-cd')
--
-- Name: cve_policy_control_script it basically updated the duplicate records of app_id, env_id,severity to delete state except for the latest one.
--

update cve_policy_control set deleted = 't' where id IN (
    select main1.id from cve_policy_control main1
                             INNER JOIN
                         (select env_id,severity,max(main.id) as max_id,count(main.id) from cve_policy_control as main where app_id is null and global='f' and deleted='f' group by env_id,severity having count(*) > 1
                         ) AS main2
                         ON main1.env_id = main2.env_id and main1.severity=main2.severity and main1.id != main2.max_id where main1.app_id is null and deleted='f' and global='f'
)



--
-- Name: cve_policy_control_script_2 it basically updated the duplicate records of env_id,severity and app_id is null to delete state except for the latest one.
--

update cve_policy_control set deleted = 't' where id IN (
    select main1.id from cve_policy_control main1
                             INNER JOIN
                         (select env_id,app_id, severity, max(main.id) as max_id,count(main.id) from cve_policy_control as main where global='f' and deleted='f' group by env_id,app_id,severity having count(*) > 1
                         ) AS main2
                         ON main1.env_id = main2.env_id and main1.app_id = main2.app_id and main1.severity=main2.severity and main1.id != main2.max_id
)INSERT INTO module(name, version, status, updated_on)
SELECT 'security.clair', version, status, now()
FROM module
WHERE name = 'cicd' and status = 'installed' and not exists (SELECT 1 FROM module where name = 'security.clair')
ALTER TABLE cd_workflow_runner
    ADD COLUMN IF NOT EXISTS  blob_storage_enabled boolean NOT NULL DEFAULT true;ALTER TABLE ci_workflow
    ADD COLUMN IF NOT EXISTS  blob_storage_enabled boolean NOT NULL DEFAULT true;CREATE SEQUENCE IF NOT EXISTS id_seq_attributes;

-- Table Definition
CREATE TABLE "public"."attributes" (
    "id" int4 NOT NULL DEFAULT nextval('id_seq_attributes'::regclass),
    "key" varchar(250) NOT NULL,
    "value" varchar(250) NOT NULL,
    "active" bool NOT NULL,
    "created_on" timestamptz,
    "created_by" integer,
    "updated_on" timestamptz,
    "updated_by" integer,
    PRIMARY KEY ("id")
);INSERT INTO module(name, version, status, updated_on)
SELECT 'notifier', version, status, now()
FROM module
WHERE name = 'cicd' and status = 'installed' and not exists (SELECT 1 FROM module where name = 'notifier');

INSERT INTO module(name, version, status, updated_on)
SELECT 'monitoring.grafana', version, status, now()
FROM module
WHERE name = 'cicd' and status = 'installed' and not exists (SELECT 1 FROM module where name = 'monitoring.grafana');CREATE SEQUENCE IF NOT EXISTS id_seq_ci_template_override;

-- Table Definition
CREATE TABLE "public"."ci_template_override"
(
    "id"                          integer NOT NULL DEFAULT nextval('id_seq_ci_template_override'::regclass),
    "ci_pipeline_id"              integer,
    "docker_registry_id"          text,
    "docker_repository"           text,
    "dockerfile_path"              text,
    "git_material_id"             integer,
    "active"                      boolean,
    "created_on"                  timestamptz,
    "created_by"                  int4,
    "updated_on"                  timestamptz,
    "updated_by"                  int4,
    CONSTRAINT "ci_template_override_ci_pipeline_id_fkey" FOREIGN KEY ("ci_pipeline_id") REFERENCES "public"."ci_pipeline" ("id"),
    CONSTRAINT "ci_template_override_git_material_id_fkey" FOREIGN KEY ("git_material_id") REFERENCES "public"."git_material" ("id"),
    PRIMARY KEY ("id")
);


ALTER TABLE "public"."ci_pipeline" ADD COLUMN "is_docker_config_overridden" boolean DEFAULT FALSE;UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
    ('reference-chart_4-15-0', '4.15.0', 't', 't', 'now()', 1, 'now()', 1);
CREATE SEQUENCE IF NOT EXISTS id_seq_global_cm_cs;

CREATE TABLE public.global_cm_cs (
"id"                            integer NOT NULL DEFAULT nextval('id_seq_smtp_config'::regclass),
"config_type"                   text,
"name"                          text,
"data"                          text,
"mount_path"                    text,
"deleted"                       bool NOT NULL DEFAULT FALSE,
"created_on"                    timestamptz,
"created_by"                    int4,
"updated_on"                    timestamptz,
"updated_by"                    int4,
PRIMARY KEY ("id")
);ALTER TABLE ci_workflow ADD pod_name text;
Update ci_workflow SET pod_name = name;


ALTER TABLE cd_workflow_runner ADD pod_name text;
Update cd_workflow_runner SET pod_name = name;ALTER TABLE global_cm_cs ADD type text;
--setting type as volume because until this release only volume type was supported
UPDATE global_cm_cs SET type='volume';

ALTER TABLE ci_template ADD COLUMN docker_build_options text;ALTER TABLE user_audit
    ADD COLUMN updated_on timestamptz;ALTER TABLE pipeline_config_override ADD COLUMN commit_time timestamptz;
UPDATE pipeline_config_override SET commit_time = updated_on;ALTER TABLE charts ADD COLUMN is_basic_view_locked bool NOT NULL DEFAULT FALSE;

ALTER TABLE charts ADD COLUMN current_view_editor text DEFAULT 'UNDEFINED';

ALTER TABLE chart_env_config_override ADD COLUMN is_basic_view_locked bool NOT NULL DEFAULT FALSE;

ALTER TABLE chart_env_config_override ADD COLUMN current_view_editor text DEFAULT 'UNDEFINED';
ALTER TABLE docker_artifact_store ALTER COLUMN  registry_url DROP NOT NULL;CREATE SEQUENCE IF NOT EXISTS id_seq_ci_build_config;

-- Table Definition
CREATE TABLE IF NOT EXISTS public.ci_build_config
(
    "id"                      integer NOT NULL DEFAULT nextval('id_seq_ci_build_config'::regclass),
    "type"                    varchar(100),
    "ci_template_id"          integer,
    "ci_template_override_id" integer,
    "build_metadata"          text,
    "created_on"              timestamptz,
    "created_by"              integer,
    "updated_on"              timestamptz,
    "updated_by"              integer,
    PRIMARY KEY ("id")
);


ALTER TABLE ci_template
    ADD COLUMN IF NOT EXISTS ci_build_config_id integer;

ALTER TABLE ONLY public.ci_template
    ADD CONSTRAINT ci_template_ci_build_config_id_fkey FOREIGN KEY (ci_build_config_id) REFERENCES public.ci_build_config(id);


ALTER TABLE ci_template_override
    ADD COLUMN IF NOT EXISTS ci_build_config_id integer;

ALTER TABLE ONLY public.ci_template_override
    ADD CONSTRAINT ci_template_override_ci_build_config_id_fkey FOREIGN KEY (ci_build_config_id) REFERENCES public.ci_build_config(id);

ALTER TABLE ci_workflow
    ADD COLUMN IF NOT EXISTS ci_build_type varchar(100);
-- Table Definition
CREATE TABLE "public"."chart_ref_metadata" (
    "chart_name" varchar(100) NOT NULL,
    "chart_description" text NOT NULL,
    PRIMARY KEY ("chart_name")
);

---Inserting Records-----
INSERT INTO "chart_ref_metadata" ("chart_name", "chart_description") VALUES
    ('Rollout Deployment', 'Chart to deploy an advanced version of Deployment that supports blue-green and canary deployments. It requires a rollout controller to run inside the cluster to function.');
INSERT INTO "chart_ref_metadata" ("chart_name", "chart_description") VALUES
    ('CronJob & Job', 'Chart to deploy a Job/CronJob. Job is a controller object that represents a finite task and CronJob can be used to schedule creation of Jobs.');
INSERT INTO "chart_ref_metadata" ("chart_name", "chart_description") VALUES
    ('Knative', 'Chart to deploy an Open-Source Enterprise-level solution to deploy Serverless apps.');
INSERT INTO "chart_ref_metadata" ("chart_name", "chart_description") VALUES
    ('Deployment', 'Chart to deploy a Deployment that runs multiple replicas of your application and automatically replaces any instances that fail or become unresponsive.');-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_docker_registry_ips_config;

-- Table Definition
CREATE TABLE "public"."docker_registry_ips_config"
(
    "id"                       int4         NOT NULL DEFAULT nextval('id_seq_docker_registry_ips_config'::regclass),
    "docker_artifact_store_id" varchar(250) NOT NULL,
    "credential_type"          varchar(50)  NOT NULL,
    "credential_value"         text,
    "applied_cluster_ids_csv"  varchar(256),
    "ignored_cluster_ids_csv"  varchar(256),
    PRIMARY KEY ("id"),
    UNIQUE("docker_artifact_store_id")
);

-- add foreign key
ALTER TABLE "public"."docker_registry_ips_config"
    ADD FOREIGN KEY ("docker_artifact_store_id") REFERENCES "public"."docker_artifact_store" ("id");

-- insert values
INSERT INTO docker_registry_ips_config (docker_artifact_store_id, credential_type, ignored_cluster_ids_csv)
SELECT id, 'SAME_AS_REGISTRY', '-1' from docker_artifact_store;UPDATE chart_ref_metadata set chart_description = 'This chart deploys an advanced version of deployment that supports Blue/Green and Canary deployments. For functioning, it requires a rollout controller to run inside the cluster.' WHERE chart_name = 'Rollout Deployment';
UPDATE chart_ref_metadata set chart_description = 'This chart deploys Job & CronJob.  A Job is a controller object that represents a finite task and CronJob is used to schedule creation of Jobs.' WHERE chart_name = 'CronJob & Job';
UPDATE chart_ref_metadata set chart_description = 'This chart deploys Knative which is an Open-Source Enterprise-level solution to deploy Serverless apps.' WHERE chart_name = 'Knative';
UPDATE chart_ref_metadata set chart_description = 'Creates a deployment that runs multiple replicas of your application and automatically replaces any instances that fail or become unresponsive.' WHERE chart_name = 'Deployment';UPDATE chart_ref_metadata SET "chart_name" = replace("chart_name", 'CronJob & Job', 'Job & CronJob');
UPDATE chart_ref SET "name" = 'Job & CronJob' WHERE "name" = 'CronJob & Job' and "user_uploaded" = false;
CREATE SEQUENCE IF NOT EXISTS id_seq_git_material_history;


CREATE TABLE public.git_material_history (
     "id" integer  NOT NULL DEFAULT nextval('id_seq_git_material_history'::regclass),
     "app_id" integer,
     "git_provider_id" integer,
     "git_material_id" integer,
     "active" boolean NOT NULL,
     "name" character varying(250),
     "url" character varying(250),
     "created_on" timestamp with time zone NOT NULL,
     "created_by" integer NOT NULL,
     "updated_on" timestamp with time zone NOT NULL,
     "updated_by" integer NOT NULL,
     "checkout_path" character varying(250),
     "fetch_submodules" boolean NOT NULL,
     PRIMARY KEY ("id"),
     CONSTRAINT git_material_history_git_material_id_fkey
         FOREIGN KEY(git_material_id)
             REFERENCES public.git_material(id)
);

ALTER TABLE public.git_material_history OWNER TO postgres;


CREATE SEQUENCE IF NOT EXISTS id_seq_ci_template_history;

CREATE TABLE public.ci_template_history (
    id integer NOT NULL DEFAULT nextval('id_seq_ci_template_history'::regclass),
    ci_template_id integer,
    app_id integer,
    docker_registry_id character varying(250),
    docker_repository character varying(250),
    dockerfile_path character varying(250),
    args text,
    before_docker_build text,
    after_docker_build text,
    template_name character varying(250),
    version character varying(250),
    target_platform VARCHAR(1000) NOT NULL DEFAULT '',
    docker_build_options text,
    active boolean,
    created_on timestamp with time zone NOT NULL,
    created_by integer NOT NULL,
    updated_on timestamp with time zone NOT NULL,
    updated_by integer NOT NULL,
    git_material_id integer,
    ci_build_config_id   integer,
    build_meta_data_type  varchar(100),
    build_metadata       text,
    trigger character varying(100),
    PRIMARY KEY ("id"),
    CONSTRAINT ci_template_history_ci_template_id_fkey
        FOREIGN KEY (ci_template_id)
            REFERENCES public.ci_template(id),
    CONSTRAINT ci_template_history_docker_registry_id_fkey
        FOREIGN KEY(docker_registry_id)
            REFERENCES public.docker_artifact_store(id),
    CONSTRAINT ci_template_history_app_id_fkey
        FOREIGN KEY(app_id)
            REFERENCES public.app(id),
    CONSTRAINT ci_template_git_material_history_id_fkey
        FOREIGN KEY(git_material_id)
            REFERENCES public.git_material(id)
);


ALTER TABLE public.ci_template OWNER TO postgres;

CREATE SEQUENCE IF NOT EXISTS id_seq_ci_pipeline_history;

CREATE TABLE public.ci_pipeline_history(
   id integer NOT NULL default nextval('id_seq_ci_pipeline_history'::regclass),
   ci_pipeline_id integer,
   ci_template_override_history text,
   ci_pipeline_material_history text,
   scan_enabled boolean,
   manual boolean,
   trigger character varying(100),
   PRIMARY KEY ("id"),
   CONSTRAINT ci_pipeline_history_ci_pipeline_id_fk
       FOREIGN KEY (ci_pipeline_id)
           REFERENCES public.ci_pipeline(id)
);

UPDATE chart_ref SET is_default=false;
INSERT INTO "public"."chart_ref" ("location", "version", "is_default", "active", "created_on", "created_by", "updated_on", "updated_by") VALUES
    ('reference-chart_4-16-0', '4.16.0', 't', 't', 'now()', 1, 'now()', 1);
ALTER TABLE "public"."external_ci_pipeline" ALTER COLUMN "access_token" DROP NOT NULL;
ALTER TABLE "public"."external_ci_pipeline" ALTER COLUMN "ci_pipeline_id" DROP NOT NULL;

ALTER TABLE "public"."ci_artifact" ADD COLUMN "external_ci_pipeline_id" int4;
ALTER TABLE "public"."ci_artifact" ADD FOREIGN KEY ("external_ci_pipeline_id") REFERENCES "public"."external_ci_pipeline" ("id");

ALTER TABLE "public"."external_ci_pipeline" ADD COLUMN "app_id" int4;
ALTER TABLE "public"."external_ci_pipeline" ADD FOREIGN KEY ("app_id") REFERENCES "public"."app" ("id");

ALTER TABLE "public"."ci_artifact" ADD COLUMN "payload_schema" text;--ADD Columns is_editable and description in external_link table
ALTER TABLE "public"."external_link" ADD COLUMN is_editable bool NOT NULL DEFAULT false;
ALTER TABLE "public"."external_link" ADD COLUMN description text;

--ADD column category for external_link_monitoring_tool
ALTER TABLE "public"."external_link_monitoring_tool" ADD COLUMN category int4;
ALTER TABLE IF EXISTS "public"."external_link_cluster_mapping" ADD COLUMN "type" int4 NOT NULL DEFAULT 0;
ALTER TABLE IF EXISTS "public"."external_link_cluster_mapping" ADD COLUMN "identifier" varchar(255) NOT NULL DEFAULT '';
ALTER TABLE IF EXISTS "public"."external_link_cluster_mapping" ADD COLUMN "env_id" int4 NOT NULL DEFAULT 0;
ALTER TABLE IF EXISTS "public"."external_link_cluster_mapping" ADD COLUMN "app_id" int4 NOT NULL DEFAULT 0;

ALTER SEQUENCE IF EXISTS id_seq_external_link_cluster_mapping RENAME TO id_seq_external_link_identifier_mapping;
ALTER TABLE IF EXISTS "public"."external_link_cluster_mapping" RENAME TO external_link_identifier_mapping;
ALTER TABLE IF EXISTS "public"."external_link_identifier_mapping" DROP CONSTRAINT external_link_cluster_mapping_cluster_id_fkey;

UPDATE "public"."external_link_monitoring_tool" SET category = 2;
UPDATE "public"."external_link_monitoring_tool" SET name = 'Webpage',category = 3 WHERE name = 'Other';
INSERT INTO "public"."external_link_monitoring_tool" ("name", "icon", "active", "created_on", "created_by", "updated_on", "updated_by", "category") VALUES
('Swagger', '', 't', 'now()', 1, 'now()', 1,2),
('Document', '', 't', 'now()', 1, 'now()', 1,1),
('Folder', '', 't', 'now()', 1, 'now()', 1,1),
('Chat', '', 't', 'now()', 1, 'now()', 1,1),
('Confluence', '', 't', 'now()', 1, 'now()', 1,1),
('Slack', '', 't', 'now()', 1, 'now()', 1,1),
('Report', '', 't', 'now()', 1, 'now()', 1,1),
('Jira', '', 't', 'now()', 1, 'now()', 1,1),
('Bugs', '', 't', 'now()', 1, 'now()', 1,3),
('Alerts', '', 't', 'now()', 1, 'now()', 1,3),
('Performance', '', 't', 'now()', 1, 'now()', 1,3);



-- Sequence and defined type
CREATE SEQUENCE IF NOT EXISTS id_seq_module_resource_status;

-- Table Definition
CREATE TABLE "public"."module_resource_status"
(
    "id"             int4         NOT NULL DEFAULT nextval('id_seq_module_resource_status'::regclass),
    "module_id"      int4         NOT NULL,
    "group"          varchar(50)  NOT NULL,
    "version"        varchar(50)  NOT NULL,
    "kind"           varchar(50)  NOT NULL,
    "name"           varchar(250) NOT NULL,
    "health_status"  varchar(50),
    "health_message" varchar(1024),
    "active"         bool,
    "created_on"     timestamptz  NOT NULL,
    "updated_on"     timestamptz,
    PRIMARY KEY ("id")
);

-- add foreign key
ALTER TABLE "public"."module_resource_status"
    ADD FOREIGN KEY ("module_id") REFERENCES "public"."module" ("id");

ALTER TABLE "public"."cluster" ADD COLUMN "k8s_version" varchar(250);