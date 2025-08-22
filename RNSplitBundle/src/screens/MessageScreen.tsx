import React from 'react';
import {View, Text, StyleSheet, FlatList} from 'react-native';

const MessageScreen = () => {
  const messages = [
    {id: '1', title: '系统消息', content: '欢迎使用新版本', time: '10:30'},
    {id: '2', title: '更新提醒', content: '有新的功能更新', time: '昨天'},
    {id: '3', title: '通知', content: '您有新的消息', time: '前天'},
  ];

  const renderItem = ({item}: any) => (
    <View style={styles.messageItem}>
      <View style={styles.messageContent}>
        <Text style={styles.messageTitle}>{item.title}</Text>
        <Text style={styles.messageText}>{item.content}</Text>
      </View>
      <Text style={styles.messageTime}>{item.time}</Text>
    </View>
  );

  return (
    <View style={styles.container}>
      <Text style={styles.title}>消息</Text>
      <FlatList
        data={messages}
        renderItem={renderItem}
        keyExtractor={item => item.id}
        contentContainerStyle={styles.listContainer}
      />
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    padding: 20,
    color: '#333',
    textAlign: 'center',
    backgroundColor: 'white',
  },
  listContainer: {
    padding: 15,
  },
  messageItem: {
    backgroundColor: 'white',
    padding: 15,
    marginBottom: 10,
    borderRadius: 10,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 1,
    },
    shadowOpacity: 0.05,
    shadowRadius: 2,
    elevation: 2,
  },
  messageContent: {
    flex: 1,
  },
  messageTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  messageText: {
    fontSize: 14,
    color: '#666',
  },
  messageTime: {
    fontSize: 12,
    color: '#999',
  },
});

export default MessageScreen;