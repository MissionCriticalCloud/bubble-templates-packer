FOLDER_NAME = 'bubble-templates'

WORKSPACE_VAR = '${WORKSPACE}'
CUSTOM_WORKSPACE_PARAM = 'CUSTOM_WORKSPACE'

PACKER_BUILD_JOB = "${FOLDER_NAME}/packer-build"
PACKER_CRON_JOB = "${FOLDER_NAME}/packer-cron"
SEED_JOB = "${FOLDER_NAME}/seed-job"

DEFAULT_GIT_REPO_BRANCH_PARAM = 'branch'

ORGANIZATION_NAME = 'MissionCriticalCloud'
ORGANIZATION_UTILS_REPOSITORY_NAME = 'organization_utils'
ORGANIZATION_UTILS_GITHUB_REPOSITORY = "${ORGANIZATION_NAME}/${ORGANIZATION_UTILS_REPOSITORY_NAME}"
ORGANIZATION_UTILS_GITHUB_DEFAULT_BRANCH = 'master'

BUBBLE_TEMPLATES_PACKER_NAME = 'bubble-templates-packer'
BUBBLE_TEMPLATES_PACKER_GITHUB_REPOSITORY = "${ORGANIZATION_NAME}/${BUBBLE_TEMPLATES_PACKER_NAME}"
BUBBLE_TEMPLATES_PACKER_GITHUB_DEFAULT_BRANCH = 'master'

TOP_LEVEL_COSMIC_JOBS_CATEGORY = 'top-level-cosmic-jobs'

MCCD_JENKINS_GITHUB_CREDENTIALS = 'f4ec9d6e-49fb-497c-bd1f-e42d88e105da'

DEFAULT_EXECUTOR = 'executor'

WORKSPACES = [
        '${WORKSPACE}/cosmic-centos-7',
        '${WORKSPACE}/cosmic-rocky-10'
]

BUBBLE_TEMPLATES_BUILD_ARTEFACTS = [
        '*/packer_output/*'
]

pipeline {
    agent {
        label "executor"
    }
    options {
        timestamps()
        ansiColor("xterm")
    }

    stages {
        stage('Build') {
            steps {
                echo 'Building..'
            }
        }
        stage('Test') {
            steps {
                echo 'Testing..'
            }
        }
        stage('Deploy') {
            steps {
                echo 'Deploying....'
            }
        }
    }
}