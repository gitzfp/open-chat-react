import React, {useEffect} from 'react';
import {NavigationContainer} from '@react-navigation/native';
import {createBottomTabNavigator} from '@react-navigation/bottom-tabs';
import {Text, Alert} from 'react-native';
import CodePush from 'react-native-code-push';

import HomeScreen from './src/screens/HomeScreen';
import DiscoverScreen from './src/screens/DiscoverScreen';
import ShopScreen from './src/screens/ShopScreen';
import MessageScreen from './src/screens/MessageScreen';
import ProfileScreen from './src/screens/ProfileScreen';

const Tab = createBottomTabNavigator();

function App(): React.JSX.Element {
  useEffect(() => {
    CodePush.sync({
      updateDialog: {
        title: '更新提示',
        optionalUpdateMessage: '有新版本可用，是否立即更新？',
        optionalInstallButtonLabel: '立即更新',
        optionalIgnoreButtonLabel: '稍后',
        mandatoryUpdateMessage: '必须更新才能继续使用',
        mandatoryContinueButtonLabel: '更新',
      },
      installMode: CodePush.InstallMode.IMMEDIATE,
    }, 
    (status) => {
      switch(status) {
        case CodePush.SyncStatus.DOWNLOADING_PACKAGE:
          console.log('正在下载更新包...');
          break;
        case CodePush.SyncStatus.INSTALLING_UPDATE:
          console.log('正在安装更新...');
          break;
        case CodePush.SyncStatus.UP_TO_DATE:
          console.log('应用已是最新版本');
          break;
        case CodePush.SyncStatus.UPDATE_INSTALLED:
          console.log('更新安装成功，正在重启应用...');
          break;
      }
    },
    ({receivedBytes, totalBytes}) => {
      const progress = (receivedBytes / totalBytes * 100).toFixed(2);
      console.log(`下载进度: ${progress}%`);
    });
  }, []);
  return (
    <NavigationContainer>
      <Tab.Navigator
        screenOptions={({route}) => ({
          tabBarIcon: ({focused, color}) => {
            let icon;
            const iconSize = focused ? 24 : 20;

            switch (route.name) {
              case '首页':
                icon = '🏠';
                break;
              case '发现':
                icon = '🔍';
                break;
              case '商城':
                icon = '🛒';
                break;
              case '消息':
                icon = '💬';
                break;
              case '我的':
                icon = '👤';
                break;
              default:
                icon = '📱';
            }

            return <Text style={{fontSize: iconSize}}>{icon}</Text>;
          },
          tabBarActiveTintColor: '#007AFF',
          tabBarInactiveTintColor: 'gray',
          tabBarStyle: {
            paddingBottom: 5,
            height: 60,
          },
          headerStyle: {
            backgroundColor: '#007AFF',
          },
          headerTintColor: '#fff',
          headerTitleStyle: {
            fontWeight: 'bold',
          },
        })}>
        <Tab.Screen name="首页" component={HomeScreen} />
        <Tab.Screen name="发现" component={DiscoverScreen} />
        <Tab.Screen name="商城" component={ShopScreen} />
        <Tab.Screen name="消息" component={MessageScreen} />
        <Tab.Screen name="我的" component={ProfileScreen} />
      </Tab.Navigator>
    </NavigationContainer>
  );
}

const codePushOptions = {
  checkFrequency: CodePush.CheckFrequency.MANUAL, // 改为手动检查，方便测试
  updateDialog: {
    title: '更新提示',
    optionalUpdateMessage: '有新版本可用，是否立即更新？',
    optionalInstallButtonLabel: '立即更新',
    optionalIgnoreButtonLabel: '稍后',
  },
  // 在Debug模式下也启用CodePush（仅用于测试）
  deploymentKey: __DEV__ ? 'YOUR_STAGING_KEY' : undefined,
};

export default CodePush(codePushOptions)(App);