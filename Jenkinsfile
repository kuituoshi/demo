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
    
    environment {
        APP_REGISTRY = 'registry-intl-vpc.cn-hongkong.aliyuncs.com/batie'
        APP_NAMESPACE = 'shop-test'
        APP_TYPE = 'springboot'
        APP_PROJECT = 'shop'
        APP_DESC = 'api'
    }

    parameters {
        string(defaultValue: 'latest', description: 'time version', name: 'timeVersion', trim: true)
        choice(choices: 'false\ntrue', description: 'Public Release?', name: 'release')
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
            }
        }
        stage('make image') {
            steps {
                container('kaniko') {
                  sh '''
                    timeTag=$(date "+%y.%m%d")
                    /kaniko/executor --context ${WORKSPACE} --cache --cache-copy-layers \
                                    --cache-repo ${APP_REGISTRY}/cache \
                                    --destination ${APP_REGISTRY}/${APP_TYPE}:${APP_PROJECT}-${APP_DESC}.${GIT_BRANCH}.${timeTag}
                    /kaniko/executor --context ${WORKSPACE} --cache --cache-copy-layers \
                                    --cache-repo ${APP_REGISTRY}/cache \
                                    --destination ${APP_REGISTRY}/${APP_TYPE}:${APP_PROJECT}-${APP_DESC}.${GIT_BRANCH}.latest
                  '''
                }
            }
        }
        stage('deploy to k8s') {
            steps {
                container('tools') {
                    withKubeConfig(credentialsId: 'k8s-inner-jenkins-admin', serverUrl: 'https://kubernetes.default') {
                        sh '''
                          kubectl -n ${APP_NAMESPACE} set image deployment/${APP_PROJECT}-${APP_DESC} web=${APP_REGISTRY}/${APP_TYPE}:${APP_PROJECT}-${APP_DESC}.${GIT_BRANCH}.${timeVersion} --record

                          if [ ${timeVersion} == 'latest' ];then
                              kubectl -n ${APP_NAMESPACE} rollout restart deployment/${APP_PROJECT}-${APP_DESC}
                          fi
                        '''
                    }
                }
            }
        }
        stage('public release') {
            when {
                anyOf {
                    environment name: 'release', value: 'true'
                }
            }
            steps {
                container('tools') {
                    withKubeConfig(credentialsId: 'k8s-outer-admin', serverUrl: 'https://172.16.9.149:6443') {
                        sh '''
                          kubectl -n ${APP_PROJECT} set image deployment/${APP_PROJECT}-${APP_DESC} web=${APP_REGISTRY}/${APP_TYPE}:${APP_PROJECT}-${APP_DESC}.${GIT_BRANCH}.${timeVersion} --record

                          if [ ${timeVersion} == 'latest' ];then
                              kubectl -n ${APP_PROJECT} rollout restart deployment/${APP_PROJECT}-${APP_DESC}
                          fi
                        '''
                    }
                }
            }
        }
    }
    post {
        failure {
            sh '''
                echo "fail"
            '''
        }
        success { 
            sh '''
                echo "success"
            '''
        }
    }
}

