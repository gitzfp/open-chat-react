import React, {useState, useEffect} from 'react';
import {
  View,
  Text,
  TouchableOpacity,
  StyleSheet,
  Alert,
  ScrollView,
  ActivityIndicator,
} from 'react-native';
import CodePush from 'react-native-code-push';

const CodePushDebugPanel = () => {
  const [syncStatus, setSyncStatus] = useState('未检查');
  const [downloadProgress, setDownloadProgress] = useState(0);
  const [updateMetadata, setUpdateMetadata] = useState<any>(null);
  const [isChecking, setIsChecking] = useState(false);
  const [isSyncing, setIsSyncing] = useState(false);

  useEffect(() => {
    // 获取当前更新元数据
    loadUpdateMetadata();
  }, []);

  const loadUpdateMetadata = async () => {
    try {
      const metadata = await CodePush.getUpdateMetadata();
      setUpdateMetadata(metadata);
    } catch (error) {
      console.log('获取更新元数据失败:', error);
    }
  };

  // 检查更新
  const checkForUpdate = async () => {
    setIsChecking(true);
    setSyncStatus('正在检查更新...');
    
    try {
      const update = await CodePush.checkForUpdate();
      
      if (update) {
        Alert.alert(
          '发现新版本',
          `版本: ${update.label}\n大小: ${(update.packageSize / 1024 / 1024).toFixed(2)} MB\n描述: ${update.description || '无'}`,
          [
            {text: '取消', style: 'cancel'},
            {text: '立即更新', onPress: () => syncImmediate()},
          ]
        );
        setSyncStatus('有可用更新');
      } else {
        setSyncStatus('已是最新版本');
        Alert.alert('提示', '当前已是最新版本');
      }
    } catch (error) {
      setSyncStatus('检查失败');
      Alert.alert('错误', '检查更新失败: ' + error);
    } finally {
      setIsChecking(false);
    }
  };

  // 立即同步更新
  const syncImmediate = async () => {
    setIsSyncing(true);
    setSyncStatus('正在同步更新...');
    
    CodePush.sync(
      {
        installMode: CodePush.InstallMode.IMMEDIATE,
        updateDialog: false,
      },
      (status) => {
        switch (status) {
          case CodePush.SyncStatus.CHECKING_FOR_UPDATE:
            setSyncStatus('正在检查更新...');
            break;
          case CodePush.SyncStatus.DOWNLOADING_PACKAGE:
            setSyncStatus('正在下载更新包...');
            break;
          case CodePush.SyncStatus.INSTALLING_UPDATE:
            setSyncStatus('正在安装更新...');
            break;
          case CodePush.SyncStatus.UP_TO_DATE:
            setSyncStatus('已是最新版本');
            setIsSyncing(false);
            break;
          case CodePush.SyncStatus.UPDATE_INSTALLED:
            setSyncStatus('更新已安装，正在重启...');
            CodePush.restartApp();
            break;
          case CodePush.SyncStatus.UNKNOWN_ERROR:
            setSyncStatus('更新失败');
            setIsSyncing(false);
            Alert.alert('错误', '更新失败');
            break;
        }
      },
      (progress) => {
        const percent = (progress.receivedBytes / progress.totalBytes * 100).toFixed(2);
        setDownloadProgress(parseFloat(percent));
        setSyncStatus(`下载中: ${percent}%`);
      }
    );
  };

  // 清除更新
  const clearUpdates = () => {
    Alert.alert(
      '确认清除',
      '这将清除所有已下载的更新，应用将恢复到原始版本',
      [
        {text: '取消', style: 'cancel'},
        {
          text: '确认清除',
          style: 'destructive',
          onPress: async () => {
            try {
              await CodePush.clearUpdates();
              Alert.alert('成功', '更新已清除，正在重启应用');
              CodePush.restartApp();
            } catch (error) {
              Alert.alert('错误', '清除更新失败: ' + error);
            }
          },
        },
      ]
    );
  };

  // 重启应用
  const restartApp = () => {
    Alert.alert(
      '确认重启',
      '是否立即重启应用？',
      [
        {text: '取消', style: 'cancel'},
        {
          text: '重启',
          onPress: () => CodePush.restartApp(),
        },
      ]
    );
  };

  if (!__DEV__) {
    return null; // 生产环境不显示调试面板
  }

  return (
    <ScrollView style={styles.container}>
      <View style={styles.panel}>
        <Text style={styles.title}>🔧 CodePush 调试面板</Text>
        
        {/* 版本信息 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>当前版本信息</Text>
          {updateMetadata ? (
            <>
              <Text style={styles.info}>标签: {updateMetadata.label || '原始版本'}</Text>
              <Text style={styles.info}>版本: {updateMetadata.appVersion || '1.0.0'}</Text>
              <Text style={styles.info}>描述: {updateMetadata.description || '无'}</Text>
              <Text style={styles.info}>强制更新: {updateMetadata.isMandatory ? '是' : '否'}</Text>
            </>
          ) : (
            <Text style={styles.info}>使用原始包版本</Text>
          )}
        </View>

        {/* 同步状态 */}
        <View style={styles.section}>
          <Text style={styles.sectionTitle}>同步状态</Text>
          <Text style={styles.status}>{syncStatus}</Text>
          {downloadProgress > 0 && downloadProgress < 100 && (
            <View style={styles.progressContainer}>
              <View style={[styles.progressBar, {width: `${downloadProgress}%`}]} />
              <Text style={styles.progressText}>{downloadProgress}%</Text>
            </View>
          )}
        </View>

        {/* 操作按钮 */}
        <View style={styles.buttonContainer}>
          <TouchableOpacity
            style={[styles.button, styles.checkButton, (isChecking || isSyncing) && styles.disabledButton]}
            onPress={checkForUpdate}
            disabled={isChecking || isSyncing}>
            {isChecking ? (
              <ActivityIndicator color="white" />
            ) : (
              <Text style={styles.buttonText}>检查更新</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.syncButton, isSyncing && styles.disabledButton]}
            onPress={syncImmediate}
            disabled={isSyncing}>
            {isSyncing ? (
              <ActivityIndicator color="white" />
            ) : (
              <Text style={styles.buttonText}>立即同步</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.clearButton]}
            onPress={clearUpdates}>
            <Text style={styles.buttonText}>清除更新</Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={[styles.button, styles.restartButton]}
            onPress={restartApp}>
            <Text style={styles.buttonText}>重启应用</Text>
          </TouchableOpacity>
        </View>

        {/* 调试提示 */}
        <View style={styles.tips}>
          <Text style={styles.tipsTitle}>💡 调试提示:</Text>
          <Text style={styles.tipsText}>1. 修改代码后，使用命令发布更新</Text>
          <Text style={styles.tipsText}>2. 点击"检查更新"测试热更新</Text>
          <Text style={styles.tipsText}>3. 如需恢复原始版本，点击"清除更新"</Text>
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  panel: {
    margin: 10,
    padding: 15,
    backgroundColor: 'white',
    borderRadius: 10,
    shadowColor: '#000',
    shadowOffset: {width: 0, height: 2},
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  title: {
    fontSize: 20,
    fontWeight: 'bold',
    textAlign: 'center',
    marginBottom: 15,
    color: '#333',
  },
  section: {
    marginBottom: 15,
    padding: 10,
    backgroundColor: '#f9f9f9',
    borderRadius: 5,
  },
  sectionTitle: {
    fontSize: 16,
    fontWeight: '600',
    marginBottom: 8,
    color: '#555',
  },
  info: {
    fontSize: 14,
    color: '#666',
    marginBottom: 4,
  },
  status: {
    fontSize: 16,
    color: '#007AFF',
    fontWeight: '500',
  },
  progressContainer: {
    height: 20,
    backgroundColor: '#e0e0e0',
    borderRadius: 10,
    marginTop: 10,
    overflow: 'hidden',
    position: 'relative',
  },
  progressBar: {
    height: '100%',
    backgroundColor: '#4CAF50',
    borderRadius: 10,
  },
  progressText: {
    position: 'absolute',
    width: '100%',
    textAlign: 'center',
    lineHeight: 20,
    color: 'white',
    fontSize: 12,
    fontWeight: 'bold',
  },
  buttonContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    marginTop: 15,
  },
  button: {
    width: '48%',
    paddingVertical: 12,
    borderRadius: 8,
    marginBottom: 10,
    alignItems: 'center',
  },
  checkButton: {
    backgroundColor: '#007AFF',
  },
  syncButton: {
    backgroundColor: '#4CAF50',
  },
  clearButton: {
    backgroundColor: '#FF9800',
  },
  restartButton: {
    backgroundColor: '#9C27B0',
  },
  disabledButton: {
    opacity: 0.5,
  },
  buttonText: {
    color: 'white',
    fontSize: 14,
    fontWeight: '600',
  },
  tips: {
    marginTop: 15,
    padding: 10,
    backgroundColor: '#FFF9C4',
    borderRadius: 5,
  },
  tipsTitle: {
    fontSize: 14,
    fontWeight: 'bold',
    marginBottom: 5,
    color: '#F57C00',
  },
  tipsText: {
    fontSize: 12,
    color: '#666',
    marginBottom: 3,
  },
});

export default CodePushDebugPanel;