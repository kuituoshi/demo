pipeline {
    options {
          buildDiscarder logRotator(numToKeepStr: '50')
          disableConcurrentBuilds()
    }
    agent {
      kubernetes {
        cloud 'kubernetes'
        workspaceVolume persistentVolumeClaimWorkspaceVolume(claimName: 'jenkins-job-workspace', readOnly: false)
        namespace 'devops'
        customWorkspace 'test'
        yamlFile 'KubernetesPod.yaml'
      }
    }
    environment {
        WORK_HOME = '/home/jenkins/agent/test'
    }
    stages {
        stage('compile source') {
            steps {
                checkout scm
                sh 'printenv'
                container('maven') {
                  sh '''
                    printenv
                    #mvn clean install -P runner
                  '''
                }
                container('kaniko') {
                  sh '''
                    printenv
                    #timeTag=$(date "+%y.%m%d")
                    #/kaniko/executor --context ${WORK_HOME} --destination registry-intl-vpc.cn-hongkong.aliyuncs.com/batie/tomcat:${GIT_BRANCH}.${timeTag}
                  '''
                  // build job: 'tdlib-core-uat', propagate: false
                }
            }
        }
    }
    post {
        failure {
            sh '''
                echo "finished"
            '''

        }
    }
}

