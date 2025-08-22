import React from 'react';
import {View, Text, StyleSheet, ScrollView, TouchableOpacity} from 'react-native';

const ShopScreen = () => {
  const products = [
    {id: '1', name: 'React Native课程', price: '¥199', tag: '热门'},
    {id: '2', name: 'TypeScript进阶', price: '¥299', tag: '新品'},
    {id: '3', name: '移动开发全栈', price: '¥599', tag: '推荐'},
    {id: '4', name: 'UI设计基础', price: '¥99', tag: '限时'},
  ];

  return (
    <ScrollView style={styles.container}>
      <View style={styles.header}>
        <Text style={styles.title}>商城</Text>
        <Text style={styles.subtitle}>精选好物</Text>
      </View>

      <View style={styles.productsContainer}>
        {products.map(product => (
          <View key={product.id} style={styles.productCard}>
            <View style={styles.productImage}>
              <Text style={styles.productImageText}>📦</Text>
            </View>
            <View style={styles.productInfo}>
              <View style={styles.tagContainer}>
                <Text style={styles.tag}>{product.tag}</Text>
              </View>
              <Text style={styles.productName}>{product.name}</Text>
              <Text style={styles.productPrice}>{product.price}</Text>
              <TouchableOpacity style={styles.buyButton}>
                <Text style={styles.buyButtonText}>立即购买</Text>
              </TouchableOpacity>
            </View>
          </View>
        ))}
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#f5f5f5',
  },
  header: {
    backgroundColor: 'white',
    padding: 20,
    alignItems: 'center',
  },
  title: {
    fontSize: 28,
    fontWeight: 'bold',
    color: '#333',
    marginBottom: 5,
  },
  subtitle: {
    fontSize: 14,
    color: '#666',
  },
  productsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    padding: 10,
  },
  productCard: {
    width: '48%',
    backgroundColor: 'white',
    margin: '1%',
    borderRadius: 10,
    padding: 15,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 3.84,
    elevation: 5,
  },
  productImage: {
    height: 100,
    backgroundColor: '#f0f0f0',
    borderRadius: 8,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: 10,
  },
  productImageText: {
    fontSize: 40,
  },
  productInfo: {
    flex: 1,
  },
  tagContainer: {
    alignSelf: 'flex-start',
    marginBottom: 5,
  },
  tag: {
    backgroundColor: '#FF6B6B',
    color: 'white',
    fontSize: 10,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 4,
  },
  productName: {
    fontSize: 14,
    fontWeight: '600',
    color: '#333',
    marginBottom: 5,
  },
  productPrice: {
    fontSize: 18,
    fontWeight: 'bold',
    color: '#FF6B6B',
    marginBottom: 10,
  },
  buyButton: {
    backgroundColor: '#007AFF',
    paddingVertical: 8,
    borderRadius: 6,
    alignItems: 'center',
  },
  buyButtonText: {
    color: 'white',
    fontSize: 12,
    fontWeight: '600',
  },
});

export default ShopScreen;