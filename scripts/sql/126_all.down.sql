ALTER TABLE public.terminal_access_templates DROP constraint terminal_access_template_name_unique;

DROP TABLE IF EXISTS "public"."terminal_access_templates";
DROP TABLE IF EXISTS "public"."user_terminal_access_data";

DROP SEQUENCE IF EXISTS public.id_seq_terminal_access_templates;
DROP SEQUENCE IF EXISTS public.id_seq_user_terminal_access_data;

delete from attributes where key = 'DEFAULT_TERMINAL_IMAGE_LIST';DELETE FROM "public"."chart_ref" WHERE ("location" = 'deployment-chart_1-0-0' AND "version" = '1.0.0');

ALTER TABLE "chart_ref" DROP COLUMN "deployment_strategy_path";
ALTER TABLE "chart_ref" DROP COLUMN "json_path_for_strategy";
ALTER TABLE "chart_ref" DROP COLUMN "is_app_metrics_supported";

DROP TABLE IF EXISTS "global_strategy_metadata" CASCADE;

DROP SEQUENCE IF EXISTS "id_seq_global_strategy_metadata";

DROP TABLE IF EXISTS "global_strategy_metadata_chart_ref_mapping" CASCADE;

DROP SEQUENCE IF EXISTS "id_seq_global_strategy_metadata_chart_ref_mapping";
DELETE FROM "public"."chart_ref" WHERE ("location" = 'cronjob-chart_1-4-0' AND "version" = '1.4.0');
UPDATE "public"."attributes" SET value = 'quay.io/devtron/ubuntu-k8s-utils:latest,quay.io/devtron/alpine-k8s-utils:latest,quay.io/devtron/centos-k8s-utils:latest,quay.io/devtron/alpine-netshoot:latest',
                                 updated_on = NOW()
WHERE key = 'DEFAULT_TERMINAL_IMAGE_LIST';

ALTER table attributes alter column value TYPE character varying(250);DELETE FROM "default_auth_role"
    WHERE role_type in ('clusterAdmin','clusterEdit','clusterView');

ALTER TABLE "roles"
    DROP COLUMN "cluster",
    DROP COLUMN "namespace",
    DROP COLUMN "group",
    DROP COLUMN "kind",
    DROP COLUMN "resource";

DELETE FROM "default_auth_policy"
    WHERE role_type in ('clusterAdmin','clusterEdit','clusterView');DROP TABLE pipeline_status_timeline_resources CASCADE;

DROP SEQUENCE IF EXISTS id_seq_pipeline_status_timeline_resources;

DROP TABLE pipeline_status_timeline_sync_detail CASCADE;

DROP SEQUENCE IF EXISTS id_seq_pipeline_status_timeline_sync_detail;

ALTER TABLE pipeline DROP COLUMN deployment_app_name;

ALTER TABLE cd_workflow_runner DROP COLUMN created_on;

ALTER TABLE cd_workflow_runner DROP COLUMN created_by;

ALTER TABLE cd_workflow_runner DROP COLUMN updated_on;

ALTER TABLE cd_workflow_runner DROP COLUMN updated_by;DELETE FROM plugin_step_variable WHERE name = 'UsePropertiesFileFromProject';

DELETE FROM plugin_step_variable WHERE name = 'CheckForSonarAnalysisReport';

DELETE FROM plugin_step_variable WHERE name = 'AbortPipelineOnPolicyCheckFailed';

UPDATE plugin_pipeline_script SET script=E'PathToCodeDir=/devtroncd$CheckoutPath
cd $PathToCodeDir
echo "sonar.projectKey=$SonarqubeProjectKey" > sonar-project.properties
docker run
--rm
-e SONAR_HOST_URL=$SonarqubeEndpoint
-e SONAR_LOGIN=$SonarqubeApiKey
-v "/$PWD:/usr/src"
sonarsource/sonar-scanner-cli' WHERE id = 2;DROP SEQUENCE IF EXISTS "id_seq_k8s_resource_history_sequence";
DROP TABLE IF EXISTS "kubernetes_resource_history";DELETE FROM plugin_step_variable WHERE name = 'SemgrepAppToken';
DELETE FROM plugin_step_variable WHERE name = 'PrefixAppNameInSemgrepBranchName';
DELETE FROM plugin_step_variable WHERE name = 'UseCommitAsSemgrepBranchName';
DELETE FROM plugin_step_variable WHERE name = 'SemgrepAppName';
DELETE FROM plugin_step_variable WHERE name = 'ExtraCommandArguments';
DELETE FROM plugin_step_variable WHERE name = 'GIT_MATERIAL_REQUEST';
DELETE FROM plugin_step_variable WHERE name = 'CodacyEndpoint'
DELETE FROM plugin_step_variable WHERE name = 'GitProvider'
DELETE FROM plugin_step_variable WHERE name = 'CodacyApiToken'
DELETE FROM plugin_step_variable WHERE name = 'Organisation'
DELETE FROM plugin_step_variable WHERE name = 'RepoName'
DELETE FROM plugin_step_variable WHERE name = 'Branch'
DELETE FROM plugin_step_variable WHERE name = 'NUMBER_OF_ISSUES'DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_3-10-0' AND "version" = '3.10.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_3-9-0' AND "version" = '3.9.0';DELETE FROM global_strategy_metadata_chart_ref_mapping WHERE chart_ref_id=(select id from chart_ref where version='1.1.0' and name='Deployment');

DELETE FROM "public"."chart_ref" WHERE ("location" = 'deployment-chart_1-1-0' AND "version" = '1.1.0');DELETE FROM global_strategy_metadata_chart_ref_mapping WHERE chart_ref_id=(select id from chart_ref where version='4.17.0' and name is null);

DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-17-0' AND "version" = '4.17.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-16-0' AND "version" = '4.16.0';DROP TABLE IF EXISTS "app_status";ALTER TABLE app_label DROP COLUMN IF EXISTS propagate;

ALTER TABLE "public"."app_label" ALTER COLUMN "key" SET DATA TYPE varchar(255);DROP TABLE IF EXISTS "public"."global_tag";

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_global_tag;DELETE FROM plugin_step_variable WHERE name = 'JiraUsername';
DELETE FROM plugin_step_variable WHERE name = 'JiraPassword';
DELETE FROM plugin_step_variable WHERE name = 'JiraBaseUrl';
DELETE FROM plugin_step_variable WHERE name = 'JiraId';DELETE FROM plugin_step_variable
WHERE plugin_step_id = (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Jira Issue Updater' and ps."index"=1 and ps.deleted=false);ALTER TABLE "public"."pipeline" DROP COLUMN "deployment_app_delete_request";
ALTER TABLE "public"."installed_apps" DROP COLUMN "deployment_app_delete_request";
update pipeline set deployment_app_delete_request=false
where deleted=true AND deployment_app_type='argo_cd' AND deployment_app_created=false;

update installed_apps set deployment_app_delete_request=false
where active=false AND deployment_app_type='argo_cd';DELETE FROM plugin_step_variable
WHERE plugin_step_id = (SELECT ps.id FROM plugin_metadata p inner JOIN plugin_step ps on ps.plugin_id=p.id WHERE p.name='Github Pull Request Updater' and ps."index"=1 and ps.deleted=false);

DELETE FROM plugin_step
WHERE plugin_id = (SELECT id FROM plugin_metadata WHERE name='Github Pull Request Updater');

DELETE FROM plugin_metadata
WHERE name = 'Github Pull Request Updater';
UPDATE "public"."chart_repo" SET "auth_mode" = '' WHERE "id" in (1,2,3,4);---- drop trigger_if_parent_stage_fail column
ALTER TABLE pipeline_stage_step DROP COLUMN IF EXISTS trigger_if_parent_stage_fail;ALTER TABLE global_cm_cs DROP COLUMN secret_ingestion_for;UPDATE ci_pipeline_material SET  active = false FROM git_material JOIN app ON app.id = git_material.app_id WHERE app.app_type = 2 AND ci_pipeline_material.git_material_id = git_material.id;

UPDATE ci_pipeline SET active = false WHERE app_id IN (SELECT id FROM app WHERE app_type = 2);

UPDATE ci_template SET active = false WHERE app_id IN (SELECT id FROM app WHERE app_type = 2);

UPDATE git_material SET active = false WHERE app_id IN (SELECT id FROM app WHERE app_type = 2);

UPDATE app_workflow_mapping SET active = false FROM app_workflow JOIN app ON app_workflow.app_id = app.id WHERE app.app_type = 2 AND app_workflow_mapping.app_workflow_id = app_workflow.id;

UPDATE app_workflow SET active = false WHERE app_id IN (SELECT id FROM app WHERE app_type = 2);

UPDATE app SET active = false WHERE app_type = 2;



ALTER table installed_apps DROP COLUMN notes;
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
    "access_type": ""
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
    "access_type": ""
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
    "access_type": ""
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
    "access_type": ""
}'
WHERE role_type='view' AND id =4;





DELETE FROM "public"."default_auth_role"
WHERE access_type='helm-app' AND entity ='apps';


UPDATE "public"."default_auth_role"
SET role_type='entitySpecificView'
WHERE role_type = 'view' AND entity='chart-group';

UPDATE "public"."default_auth_role"
SET role_type='roleSpecific'
WHERE role_type = 'update' AND entity='chart-group';

UPDATE "public"."default_auth_role"
SET role_type='entitySpecificAdmin'
WHERE role_type = 'admin' AND entity='chart-group';

UPDATE "public"."default_auth_role"
SET role_type='clusterEdit'
WHERE role_type = 'edit' AND  entity = 'cluster';

UPDATE "public"."default_auth_role"
SET role_type='clusterView'
WHERE role_type = 'view' AND  entity = 'cluster';

UPDATE "public"."default_auth_role"
SET role_type='clusterAdmin'
WHERE role_type = 'admin' AND  entity = 'cluster';

ALTER TABLE "public"."default_auth_role"
DROP COLUMN access_type;

ALTER TABLE "public"."default_auth_role"
DROP COLUMN entity;

DELETE FROM "public"."default_auth_policy"
WHERE access_type = 'helm-app' AND entity ='apps';

UPDATE "public"."default_auth_policy"
SET role_type='clusterEdit'
WHERE role_type = 'edit' AND  entity = 'cluster';

UPDATE "public"."default_auth_policy"
SET role_type='clusterView'
WHERE role_type = 'view' AND  entity = 'cluster';

UPDATE "public"."default_auth_policy"
SET role_type='clusterAdmin'
WHERE role_type = 'admin' AND  entity = 'cluster';

UPDATE "public"."default_auth_policy"
SET role_type='entitySpecific'
WHERE role_type = 'update' AND entity = 'chart-group';

UPDATE "public"."default_auth_policy"
SET  role_type='entityView'
WHERE role_type = 'view' AND entity = 'chart-group';

UPDATE "public"."default_auth_policy"
SET role_type='entityAll'
WHERE role_type = 'admin' AND entity = 'chart-group';

ALTER TABLE "public"."default_auth_policy"
DROP COLUMN access_type;

ALTER TABLE "public"."default_auth_policy"
DROP COLUMN entity;





ALTER TABLE "public"."global_tag" ALTER COLUMN "key" SET DATA TYPE varchar(100);CREATE UNIQUE INDEX "app_app_name_key" ON "public"."app" USING BTREE ("app_name");DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_3-11-0' AND "version" = '3.11.0');
UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_3-10-0' AND "version" = '3.10.0';
ALTER TABLE gitops_config DROP COLUMN column_name;DROP TABLE "public"."bulk_update_readme" CASCADE;DROP INDEX "public"."cdwf_pipeline_id_idx";
DROP INDEX "public"."pco_pipeline_id_idx";
DROP INDEX "public"."cdwfr_cd_workflow_id_idx";ALTER TABLE ONLY public.image_scan_deploy_info
    ADD CONSTRAINT image_scan_deploy_info_scan_object_meta_id_fkey FOREIGN KEY (scan_object_meta_id) REFERENCES public.image_scan_object_meta(id);
UPDATE "public"."bulk_update_readme"
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


The following tables list the configurable parameters of the Payload component in the Script and their description along with example.

| Parameter                      | Description                        | Example                                                    |
| -------------------------- | ---------------------------------- | ---------------------------------------------------------- |
|`includes.names `        | Will filter apps having exact string or similar substrings                 | `["app%","%abc", "xyz"]` (will include all apps having `"app%"` **OR** `"%abc"` as one of their substring, example - app1, app-test, test-abc etc. **OR** application with name xyz)    |
| `excludes.names`          | Will filter apps not having exact string or similar substrings.              | `["%z","%y", "abc"]`       (will filter out all apps having `"%z"` **OR** `"%y"` as one of their substring, example - appz, test-app-y etc. **OR** application with name abc)                                        |
| `envIds`       | List of envIds to be updated for the selected applications.           | `[1,2,3]`                                                   |
| `global`       | Flag to update global deployment template of applications.            | `true`,`false`                                                        |
| `deploymentTemplate.spec.patchJson`       | String having the update operation(you can apply more than one changes at a time). It supports [JSON patch ](http://jsonpatch.com/) specifications for update. | `''[ { "op": "add", "path": "/MaxSurge", "value": 1 }, { "op": "replace", "path": "/GracePeriod", "value": "30" }]''` |
| `configMap.spec.names`      | Names of all ConfigMaps to be updated. | `configmap1`,`configmap2`,`configmap3` |
| `secret.spec.names`      | Names of all Secrets to be updated. | `secret1`,`secret2`|
| `configMap.spec.patchJson` / `secret.spec.patchJson`       | String having the update operation for ConfigMaps/Secrets(you can apply more than one changes at a time). It supports [JSON patch ](http://jsonpatch.com/) specifications for update. | `''[{ "op": "add", "path": "/{key}", "value": "{value}" },{"op": "replace","path":"/{key}","value": "{value}"}]''`(Replace the `{key}` part to the key you want to perform operation on & `{value}`is the key''s corresponding value |
' WHERE "id" = 1;---- drop column git_host_id from git_provider
ALTER TABLE git_provider
    DROP COLUMN git_host_id;

---- drop table git_host
DROP TABLE git_host;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.git_host_id_seq;
DROP TABLE "public"."cd_workflow_runner" CASCADE;

DROP TABLE "public"."chart_ref" CASCADE;

DROP TABLE "public"."role_group_role_mapping" CASCADE;

DROP TABLE "public"."helm_values" CASCADE;

DROP TABLE "public"."slack_config" CASCADE;

DROP TABLE "public"."image_scan_deploy_info" CASCADE;

DROP TABLE "public"."app" CASCADE;

DROP TABLE "public"."notification_settings_view" CASCADE;

DROP TABLE "public"."ci_pipeline" CASCADE;

DROP TABLE "public"."config_map_app_level" CASCADE;

DROP TABLE "public"."external_ci_pipeline" CASCADE;

DROP TABLE "public"."app_store_version_values" CASCADE;

DROP TABLE "public"."pipeline_strategy" CASCADE;

DROP TABLE "public"."chart_env_config_override" CASCADE;

DROP TABLE "public"."config_map_env_level" CASCADE;

DROP TABLE "public"."deployment_status" CASCADE;

DROP TABLE "public"."pipeline_config_override" CASCADE;

DROP TABLE "public"."cluster" CASCADE;

DROP TABLE "public"."cve_store" CASCADE;

DROP TABLE "public"."image_scan_execution_history" CASCADE;

DROP TABLE "public"."image_scan_execution_result" CASCADE;

DROP TABLE "public"."image_scan_object_meta" CASCADE;

DROP TABLE "public"."environment" CASCADE;

DROP TABLE "public"."app_store_application_version" CASCADE;

DROP TABLE "public"."ci_pipeline_material" CASCADE;

DROP TABLE "public"."roles" CASCADE;

DROP TABLE "public"."env_level_app_metrics" CASCADE;

DROP TABLE "public"."team" CASCADE;

DROP TABLE "public"."config_map_pipeline_level" CASCADE;

DROP TABLE "public"."app_level_metrics" CASCADE;

DROP TABLE "public"."db_migration_config" CASCADE;

DROP TABLE "public"."cd_workflow_config" CASCADE;

DROP TABLE "public"."charts" CASCADE;

DROP TABLE "public"."pipeline" CASCADE;

DROP TABLE "public"."deployment_group_app" CASCADE;

DROP TABLE "public"."cluster_helm_config" CASCADE;

DROP TABLE "public"."app_store" CASCADE;

DROP TABLE "public"."cve_policy_control" CASCADE;

DROP TABLE "public"."chart_repo" CASCADE;

DROP TABLE "public"."docker_artifact_store" CASCADE;

DROP TABLE "public"."chart_group_entry" CASCADE;

DROP TABLE "public"."notification_templates" CASCADE;

DROP TABLE "public"."chart_group" CASCADE;

DROP TABLE "public"."users" CASCADE;

DROP TABLE "public"."chart_group_deployment" CASCADE;

DROP TABLE "public"."ci_workflow_config" CASCADE;

DROP TABLE "public"."installed_apps" CASCADE;

DROP TABLE "public"."app_workflow_mapping" CASCADE;

DROP TABLE "public"."event" CASCADE;

DROP TABLE "public"."ci_template" CASCADE;

DROP TABLE "public"."notifier_event_log" CASCADE;

DROP TABLE "public"."ci_workflow" CASCADE;

DROP TABLE "public"."role_group" CASCADE;

DROP TABLE "public"."cluster_installed_apps" CASCADE;

DROP TABLE "public"."deployment_group" CASCADE;

DROP TABLE "public"."installed_app_versions" CASCADE;

DROP TABLE "public"."notification_settings" CASCADE;

DROP TABLE "public"."ses_config" CASCADE;

DROP TABLE "public"."ci_pipeline_scripts" CASCADE;

DROP TABLE "public"."user_roles" CASCADE;

DROP TABLE "public"."app_workflow" CASCADE;

DROP TABLE "public"."cd_workflow" CASCADE;

DROP TABLE "public"."db_config" CASCADE;

DROP TABLE "public"."cluster_accounts" CASCADE;

DROP TABLE "public"."git_web_hook" CASCADE;

DROP TABLE "public"."events" CASCADE;

DROP TABLE "public"."project_management_tool_config" CASCADE;

DROP TABLE "public"."app_env_linkouts" CASCADE;

DROP TABLE "public"."git_material" CASCADE;

DROP TABLE "public"."job_event" CASCADE;

DROP TABLE "public"."ci_artifact" CASCADE;

DROP TABLE "public"."git_provider" CASCADE;---- drop table webhook_event_data
DROP TABLE IF EXISTS webhook_event_data;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.webhook_event_data_id_seq;
DROP TABLE "public"."app_label" CASCADE;ALTER TABLE docker_artifact_store
ALTER COLUMN password type character varying(250)DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_3-12-0' AND "version" = '3.12.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_3-11-0' AND "version" = '3.11.0';ALTER TABLE "public"."docker_artifact_store" DROP COLUMN "connection";

ALTER TABLE "public"."docker_artifact_store" DROP COLUMN "cert";---- ALTER TABLE git_provider - modify type
ALTER TABLE git_provider
ALTER COLUMN ssh_private_key TYPE varchar(250);

---- ALTER TABLE git_provider - rename column
ALTER TABLE git_provider
RENAME COLUMN ssh_private_key TO ssh_key;

---- ALTER TABLE git_material - drop column
ALTER TABLE git_material
DROP COLUMN IF EXISTS fetch_submodules
---- ALTER TABLE gitops_config - drop column
ALTER TABLE gitops_config
    DROP COLUMN IF EXISTS bitbucket_workspace_id,
    DROP COLUMN IF EXISTS bitbucket_project_key;DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-10-0' AND "version" = '4.10.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_3-12-0' AND "version" = '3.12.0';
ALTER TABLE "public"."chart_ref" DROP COLUMN "name";

ALTER TABLE "public"."chart_ref" DROP COLUMN "chart_data";DELETE FROM "public"."chart_ref" WHERE ("location" = 'cronjob-chart_1-2-0' AND "version" = '1.2.0');
DELETE FROM "public"."chart_ref" WHERE ("location" = 'knative-chart_1-1-0' AND "version" = '1.1.0');
ALTER TABLE "public"."installed_app_versions" ADD COLUMN "values_yaml" text;DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-11-0' AND "version" = '4.11.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-10-0' AND "version" = '4.10.0';
ALTER TABLE "public"."roles" DROP COLUMN IF EXISTS "access_type";

---- DROP Index
DROP INDEX IF EXISTS "public"."role_unique";
CREATE UNIQUE INDEX IF NOT EXISTS "role_unique" ON "public"."roles" USING BTREE ("role");ALTER TABLE "public"."environment" DROP COLUMN "environment_identifier";DROP TABLE "public"."default_auth_policy" CASCADE;

DROP TABLE "public"."default_auth_role" CASCADE;ALTER TABLE chart_group DROP COLUMN IF EXISTS deleted;

ALTER TABLE chart_repo DROP COLUMN IF EXISTS deleted;

ALTER TABLE slack_config DROP COLUMN IF EXISTS deleted;

ALTER TABLE ses_config DROP COLUMN IF EXISTS deleted;

ALTER TABLE git_provider DROP COLUMN IF EXISTS deleted;

ALTER TABLE team ADD CONSTRAINT team_name_key UNIQUE (name);

ALTER TABLE git_provider ADD CONSTRAINT git_provider_name_key UNIQUE (name);

ALTER TABLE git_provider ADD CONSTRAINT git_provider_url_key UNIQUE (url);

ALTER TABLE chart_group ADD CONSTRAINT chart_group_name_key UNIQUE (name);----empty script as up.sql for this contains dropping redundant tablesALTER TABLE app
DROP COLUMN IF EXISTS app_offering_mode;ALTER TABLE "public"."installed_apps" DROP COLUMN "git_ops_repo_name";DROP TABLE "public"."config_map_history" CASCADE;
DROP TABLE "public"."deployment_template_history" CASCADE;
DROP TABLE "public"."app_store_charts_history" CASCADE;
DROP TABLE "public"."pre_post_ci_script_history" CASCADE;
DROP TABLE "public"."pre_post_cd_script_history" CASCADE;
DROP TABLE "public"."pipeline_strategy_history" CASCADE;DROP INDEX "public"."version_history_git_hash_index";

DROP TABLE "public"."installed_app_version_history" CASCADE;DROP TABLE "public"."sso_login_config" CASCADE;DELETE FROM "public"."chart_ref" WHERE ("location" = 'cronjob-chart_1-3-0' AND "version" = '1.3.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'cronjob-chart_1-2-0' AND "version" = '1.2.0';

UPDATE chart_ref SET name = replace(name, 'CronJob & Job', 'Cron Job & Job');CREATE TABLE "public"."app_store_charts_history"
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
);DROP TABLE "public"."external_link_cluster_mapping" CASCADE;

DROP TABLE "public"."external_link_monitoring_tool" CASCADE;

DROP TABLE "public"."external_link" CASCADE;DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-12-0' AND "version" = '4.12.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-11-0' AND "version" = '4.11.0';
DELETE FROM "public"."chart_ref" WHERE ("location" = 'workflow-chart_1-0-0' AND "version" = '1.0.0');
UPDATE git_provider
SET git_host_id=NULL
WHERE id = 1;DROP TABLE "public"."server_action_audit_log" CASCADE;

DROP TABLE "public"."module_action_audit_log" CASCADE;

DROP TABLE "public"."module" CASCADE;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_module;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_module_action_audit_log;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_server_action_audit_log;ALTER TABLE gitops_config
    DROP COLUMN email_id;DROP TABLE IF EXISTS "public"."self_registration_roles";
DROP TABLE "public"."plugin_metadata" CASCADE;
DROP TABLE "public"."plugin_tag" CASCADE;
DROP TABLE "public"."plugin_tag_relation" CASCADE;
DROP TABLE "public"."plugin_pipeline_script" CASCADE;
DROP TABLE "public"."script_path_arg_port_mapping" CASCADE;
DROP TABLE "public"."plugin_step" CASCADE;
DROP TABLE "public"."plugin_step_variable" CASCADE;
DROP TABLE "public"."plugin_step_condition" CASCADE;
DROP TABLE "public"."pipeline_stage" CASCADE;
DROP TABLE "public"."pipeline_stage_step" CASCADE;
DROP TABLE "public"."pipeline_stage_step_variable" CASCADE;
DROP TABLE "public"."pipeline_stage_step_condition" CASCADE;ALTER TABLE "public"."chart_repo" DROP COLUMN "user_name";
ALTER TABLE "public"."chart_repo" DROP COLUMN "password";
ALTER TABLE "public"."chart_repo" DROP COLUMN "ssh_key";
ALTER TABLE "public"."chart_repo" DROP COLUMN "access_token";
ALTER TABLE "public"."chart_repo" DROP COLUMN "auth_mode";ALTER TABLE pipeline_strategy_history
    DROP COLUMN pipeline_trigger_type;ALTER TABLE "public"."external_link" ALTER COLUMN "url" SET DATA TYPE varchar(255);ALTER TABLE "public"."charts" ALTER COLUMN "chart_location" SET NOT NULL;

ALTER TABLE "public"."charts" ALTER COLUMN "git_repo_url" SET NOT NULL;

ALTER TABLE "public"."pipeline" DROP COLUMN "deployment_app_created";ALTER TABLE chart_ref DROP COLUMN chart_description;
ALTER TABLE chart_ref DROP COLUMN user_uploaded;
DROP TABLE "public"."api_token" CASCADE;

DROP TABLE "public"."user_audit" CASCADE;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_api_token;

DROP SEQUENCE IF EXISTS public.id_seq_user_audit;

---- DROP index
DROP INDEX IF EXISTS public.user_audit_user_id_IX;

-- drop column
ALTER TABLE "public"."users" DROP COLUMN IF EXISTS "user_type";

-- delete apiTokenSecret from attributes
DELETE FROM attributes WHERE key = 'apiTokenSecret';ALTER TABLE "public"."pipeline" DROP COLUMN "deployment_app_type";
ALTER TABLE "public"."charts" DROP COLUMN "reference_chart";ALTER TABLE "public"."installed_apps" DROP COLUMN "deployment_app_type";ALTER TABLE cluster
    DROP COLUMN error_in_connecting;DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-13-0' AND "version" = '4.13.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-12-0' AND "version" = '4.12.0';
ALTER TABLE "public"."cluster" DROP COLUMN "agent_installation_stage";DROP TABLE "public"."smtp_config" CASCADE;ALTER TABLE ci_template
    DROP COLUMN target_platform;ALTER TABLE app_store_application_version DROP COLUMN IF EXISTS values_schema_json;

ALTER TABLE app_store_application_version DROP COLUMN IF EXISTS notes;ALTER TABLE app_store_version_values DROP COLUMN IF EXISTS description;---- DROP index
DROP INDEX IF EXISTS public.image_scan_execution_history_id_IX;DROP TABLE "public"."pipeline_status_timeline" CASCADE;---- DROP index
DROP INDEX IF EXISTS public.app_store_application_version_app_store_id_IX;---- revert notification template update for CI trigger ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI triggered for app: {{appName}}",
 "html": "<b>CI triggered on pipeline: {{pipelineName}}</b>"}'
where channel_type = 'ses'
and node_type = 'CI'
and event_type_id = 1;


---- revert notification template update for CI success ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI success for app: {{appName}}",
 "html": "<b>CI success on pipeline: {{pipelineName}}</b><br><b>docker image: {{{dockerImageUrl}}}</b><br><b>Source: {{source}}</b><br>"}'
where channel_type = 'ses'
and node_type = 'CI'
and event_type_id = 2;



---- revert notification template update for CI fail ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CI failed for app: {{appName}}",
 "html": "<b>CI failed on pipeline: {{pipelineName}}</b><br><b>build name: {{buildName}}</b><br><b>Pod status: {{podStatus}}</b><br><b>message: {{message}}</b>"}'
where channel_type = 'ses'
and node_type = 'CI'
and event_type_id = 3;


---- revert notification template update for CD trigger ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD triggered for app: {{appName}} on environment: {{envName}}",
 "html": "<b>CD triggered for app: {{appName}} on environment: {{envName}}</b> <br> <b>Docker image: {{{dockerImageUrl}}}</b> <br> <b>Source snapshot: {{source}}</b> <br> <b>pipeline: {{pipelineName}}</b>"}'
where channel_type = 'ses'
and node_type = 'CD'
and event_type_id = 1;



---- revert notification template update for CD success ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD success for app: {{appName}} on environment: {{envName}}",
 "html": "<b>CD success for app: {{appName}} on environment: {{envName}}</b>"}'
where channel_type = 'ses'
and node_type = 'CD'
and event_type_id = 2;


---- revert notification template update for CD fail ses/smtp
UPDATE notification_templates
set template_payload = '{"from": "{{fromEmail}}",
 "to": "{{toEmail}}",
 "subject": "CD failed for app: {{appName}} on environment: {{envName}}",
 "html": "<b>CD failed for app: {{appName}} on environment: {{envName}}</b>"}'
where channel_type = 'ses'
and node_type = 'CD'
and event_type_id = 3;ALTER TABLE ci_pipeline_material DROP COLUMN regex;UPDATE pipeline_status_timeline
SET status ='KUBECTL APPLY SYNCED'
WHERE status = 'KUBECTL_APPLY_SYNCED';

UPDATE pipeline_status_timeline
SET status ='KUBECTL APPLY STARTED'
WHERE status = 'KUBECTL_APPLY_STARTED';

UPDATE pipeline_status_timeline
SET status ='GIT COMMIT'
WHERE status = 'GIT_COMMIT';DROP TABLE "public"."gitops_config" CASCADE;---- revert notification template update for CI trigger slack
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


---- revert notification template update for CI success slack
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



---- revert notification template update for CI fail slack
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


---- revert notification template update for CD trigger slack
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



---- revert notification template update for CD success slack
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


---- revert notification template update for CD fail slack
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
and event_type_id = 3;DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-14-0' AND "version" = '4.14.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-13-0' AND "version" = '4.13.0';
DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_3-13-0' AND "version" = '3.13.0');
DROP TABLE IF EXISTS "public"."user_attributes";delete from module where name = 'argo-cd';delete from module where name = 'security.clair';ALTER TABLE cd_workflow_runner
    DROP COLUMN IF EXISTS blob_storage_enabled;ALTER TABLE ci_workflow
    DROP COLUMN IF EXISTS  blob_storage_enabled;DROP TABLE "public"."attributes" CASCADE;delete from module where name = 'notifier';
delete from module where name = 'monitoring.grafana';DROP TABLE "public"."ci_template_override" CASCADE;

ALTER TABLE "public"."ci_pipeline" DROP COLUMN "is_docker_config_overridden";DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-15-0' AND "version" = '4.15.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-14-0' AND "version" = '4.14.0';DROP TABLE "public"."global_cm_cs" CASCADE;ALTER TABLE ci_workflow DROP COLUMN pod_name;

ALTER TABLE cd_workflow_runner DROP COLUMN pod_name;
ALTER TABLE global_cm_cs DROP COLUMN type;ALTER TABLE ci_template DROP COLUMN docker_build_options;ALTER TABLE user_audit
    DROP COLUMN updated_on;ALTER TABLE pipeline_config_override DROP COLUMN commit_time;ALTER TABLE charts DROP COLUMN is_basic_view_locked;

ALTER TABLE charts DROP COLUMN current_view_editor;

ALTER TABLE chart_env_config_override DROP COLUMN is_basic_view_locked;

ALTER TABLE chart_env_config_override DROP COLUMN current_view_editor;ALTER TABLE docker_artifact_store ALTER COLUMN  registry_url  SET NOT NULL;
ALTER TABLE ci_template DROP COLUMN IF EXISTS ci_build_config_id;
ALTER TABLE ci_template_override DROP COLUMN IF EXISTS ci_build_config_id;

DROP TABLE IF EXISTS "public"."ci_build_config";

ALTER TABLE ci_workflow
    DROP COLUMN IF EXISTS ci_build_type;DROP TABLE "public"."chart_ref_metadata" CASCADE;
DROP TABLE "public"."docker_registry_ips_config" CASCADE;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_docker_registry_ips_config;UPDATE chart_ref_metadata set chart_description = 'Chart to deploy an advanced version of Deployment that supports blue-green and canary deployments. It requires a rollout controller to run inside the cluster to function.' WHERE chart_name = 'Rollout Deployment';
UPDATE chart_ref_metadata set chart_description = 'Chart to deploy a Job/CronJob. Job is a controller object that represents a finite task and CronJob can be used to schedule creation of Jobs.' WHERE chart_name = 'CronJob & Job';
UPDATE chart_ref_metadata set chart_description = 'Chart to deploy an Open-Source Enterprise-level solution to deploy Serverless apps.' WHERE chart_name = 'Knative';
UPDATE chart_ref_metadata set chart_description = 'Chart to deploy a Deployment that runs multiple replicas of your application and automatically replaces any instances that fail or become unresponsive.' WHERE chart_name = 'Deployment';UPDATE chart_ref_metadata SET "chart_name" = replace("chart_name", 'Job & CronJob', 'CronJob & Job');
UPDATE chart_ref SET "name" = 'CronJob & Job' WHERE "name" = 'Job & CronJob' and "user_uploaded" = false;
DROP TABLE IF EXISTS "public"."git_material_history";
DROP TABLE IF EXISTS "public"."ci_template_history";
DROP TABLE IF EXISTS "public"."ci_pipeline_history";DELETE FROM "public"."chart_ref" WHERE ("location" = 'reference-chart_4-16-0' AND "version" = '4.16.0');

UPDATE "public"."chart_ref" SET "is_default" = 't' WHERE "location" = 'reference-chart_4-15-0' AND "version" = '4.15.0';ALTER TABLE "public"."external_ci_pipeline" ALTER COLUMN "ci_pipeline_id" SET NOT NULL;

ALTER TABLE "public"."external_ci_pipeline" ALTER COLUMN "access_token" SET NOT NULL;

ALTER TABLE "public"."external_ci_pipeline" DROP COLUMN "app_id";

ALTER TABLE "public"."ci_artifact" DROP COLUMN "external_ci_pipeline_id";

ALTER TABLE "public"."ci_artifact" DROP COLUMN "payload_schema";ALTER TABLE "public"."external_link" DROP COLUMN is_editable;
ALTER TABLE "public"."external_link" DROP COLUMN description;

ALTER TABLE "public"."external_link_monitoring_tool" DROP COLUMN category;

ALTER TABLE IF EXISTS "public"."external_link_identifier_mapping" DROP COLUMN "type";
ALTER TABLE IF EXISTS "public"."external_link_identifier_mapping" DROP COLUMN "identifier";
ALTER TABLE IF EXISTS "public"."external_link_identifier_mapping" DROP COLUMN "env_id";
ALTER TABLE IF EXISTS "public"."external_link_identifier_mapping" DROP COLUMN "app_id";

ALTER SEQUENCE IF EXISTS id_seq_external_link_identifier_mapping RENAME TO id_seq_external_link_cluster_mapping;
ALTER TABLE IF EXISTS "public"."external_link_identifier_mapping" RENAME TO external_link_cluster_mapping;
DROP TABLE "public"."module_resource_status" CASCADE;

---- DROP sequence
DROP SEQUENCE IF EXISTS public.id_seq_module_resource_status;ALTER TABLE "public"."cluster" DROP COLUMN "k8s_version";