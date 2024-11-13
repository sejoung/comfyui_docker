#!/usr/bin/env groovy

def getCommitMsg() {
  return sh(script: """git log --format="%s - %aN" -1""", returnStdout: true)
}

def getGitCommitPretty() {
  return sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'")
}

def sendMessage(emoji, color) {
  def commitMsg = getCommitMsg()
  slackSend(channel: '#build', attachments: [
    [
      color : color,
      title : "${emoji} comfy ui docker build",
      text  : """<${env.BUILD_URL}|${env.JOB_NAME} (#${env.BUILD_ID})>
BUILD_IMAGE_NAME : ${IMAGE_NAME}
${commitMsg}""",
      footer: currentBuild.durationString.replace(' and counting', '')
    ]
  ]
  )
}

pipeline {
  agent any

  options {
    disableConcurrentBuilds()
    parallelsAlwaysFailFast()
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '3', daysToKeepStr: '30', numToKeepStr: '3')
  }

  environment {
    IMAGE_NAME = "${env.BRANCH_NAME.replace("/", "_")}_${getGitCommitPretty()}"
  }

  stages {
    stage('checkout') {
      steps {
        checkout scm
      }
    }

    stage('prepared') {
      steps {
        sendMessage('🚙 start', 'warning')
      }
    }

    stage('docker build') {
      steps {
        sh 'docker build -t ${IMAGE_NAME} .'
      }
    }


  }

  post {
    success {
      sendMessage('👍 success', 'good')
    }
    failure {
      sendMessage('😭 fail', 'danger')
    }
  }
}
