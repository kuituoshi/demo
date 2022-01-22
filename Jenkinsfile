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
        yamlFile 'KubernetesPod.yaml'
      }
    }
    
    stages {
        stage('compile source') {
            steps {
                checkout scm
                container('maven') {
                  sh '''
                    mvn clean install -P runner
                  '''
                }
                container('kaniko') {
                  sh '''
                    timeTag=$(date "+%y.%m%d")
                    /kaniko/executor --context ${WORKSPACE} --destination registry-intl-vpc.cn-hongkong.aliyuncs.com/batie/tomcat:shop-api.${GIT_BRANCH}.${timeTag}
                  '''
                  // build job: 'tdlib-core-uat', propagate: false
                }
            }
        }
    }
    post {
        failure {
            sh '''
                echo "failed"
            '''

        }
    }
}

