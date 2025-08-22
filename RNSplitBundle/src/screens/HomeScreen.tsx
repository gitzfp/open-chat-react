import React, {useState, useEffect} from 'react';
import {View, Text, StyleSheet, TouchableOpacity, Alert, ScrollView} from 'react-native';
import CodePush from 'react-native-code-push';
import CodePushDebugPanel from '../components/CodePushDebugPanel';

const HomeScreen = () => {
  const [counter, setCounter] = useState(0);
  const [updateInfo, setUpdateInfo] = useState({
    label: '',
    version: '',
    description: '',
  });
  const [isChecking, setIsChecking] = useState(false);

  useEffect(() => {
    CodePush.getUpdateMetadata().then((metadata) => {
      if (metadata) {
        setUpdateInfo({
          label: metadata.label || 'v1',
          version: metadata.appVersion || '1.0.0',
          description: metadata.description || '初始版本',
        });
      } else {
        setUpdateInfo({
          label: 'v1',
          version: '1.0.0',
          description: '初始版本',
        });
      }
    });
  }, []);

  const checkForUpdate = () => {
    setIsChecking(true);
    CodePush.sync({
      updateDialog: {
        title: '检查更新',
        optionalUpdateMessage: '发现新版本，是否立即更新？',
        optionalInstallButtonLabel: '立即更新',
        optionalIgnoreButtonLabel: '稍后',
        mandatoryUpdateMessage: '必须更新才能继续使用',
        mandatoryContinueButtonLabel: '更新',
      },
      installMode: CodePush.InstallMode.IMMEDIATE,
    },
    (status) => {
      switch(status) {
        case CodePush.SyncStatus.UP_TO_DATE:
          Alert.alert('提示', '当前已是最新版本');
          break;
        case CodePush.SyncStatus.UPDATE_INSTALLED:
          Alert.alert('提示', '更新成功，正在重启应用');
          break;
      }
      setIsChecking(false);
    },
    (progress) => {
      console.log(`下载进度: ${(progress.receivedBytes / progress.totalBytes * 100).toFixed(2)}%`);
    });
  };

  return (
    <ScrollView style={styles.scrollContainer}>
      <View style={styles.container}>
      <Text style={styles.title}>首页 - 热更新测试</Text>
      <Text style={styles.subtitle}>热更新成功！这是首页Tab</Text>
      
      <View style={styles.versionContainer}>
        <Text style={styles.versionTitle}>当前版本信息</Text>
        <Text style={styles.versionText}>应用版本: {updateInfo.version}</Text>
        <Text style={styles.versionText}>更新标签: {updateInfo.label}</Text>
        <Text style={styles.versionText}>更新描述: {updateInfo.description}</Text>
      </View>
      
      <View style={styles.counterContainer}>
        <Text style={styles.counterText}>计数器: {counter}</Text>
        <TouchableOpacity 
          style={styles.button}
          onPress={() => setCounter(counter + 1)}>
          <Text style={styles.buttonText}>点击 +1</Text>
        </TouchableOpacity>
      </View>
      
      <TouchableOpacity 
        style={[styles.updateButton, isChecking && styles.disabledButton]}
        onPress={checkForUpdate}
        disabled={isChecking}>
        <Text style={styles.updateButtonText}>
          {isChecking ? '检查中...' : '检查更新'}
        </Text>
      </TouchableOpacity>
      
      {/* 开发模式下显示调试面板 */}
      {__DEV__ && <CodePushDebugPanel />}
    </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  scrollContainer: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: 20,
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#333',
  },
  subtitle: {
    fontSize: 16,
    color: '#666',
    marginBottom: 30,
  },
  counterContainer: {
    alignItems: 'center',
  },
  counterText: {
    fontSize: 20,
    marginBottom: 20,
    color: '#333',
  },
  button: {
    backgroundColor: '#007AFF',
    paddingHorizontal: 30,
    paddingVertical: 12,
    borderRadius: 8,
  },
  buttonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  versionContainer: {
    backgroundColor: 'white',
    padding: 20,
    borderRadius: 10,
    marginBottom: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  versionTitle: {
    fontSize: 18,
    fontWeight: 'bold',
    marginBottom: 10,
    color: '#007AFF',
  },
  versionText: {
    fontSize: 14,
    color: '#666',
    marginBottom: 5,
  },
  updateButton: {
    backgroundColor: '#34C759',
    paddingHorizontal: 30,
    paddingVertical: 12,
    borderRadius: 8,
    marginTop: 20,
  },
  updateButtonText: {
    color: 'white',
    fontSize: 16,
    fontWeight: '600',
  },
  disabledButton: {
    opacity: 0.6,
  },
});

export default HomeScreen;