require("dotenv").config();

const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

const { MongoClient } = require("mongodb");

const client = new MongoClient(process.env.MONGODB_URI);

const products = [
  {
    name: "Backpack",
    price: 1499,
    imageUrl: "https://images.unsplash.com/photo-1553062407-98eeb64c6a62",
    description: "Spacious backpack suitable for college, work and travel."
  },
  {
    name: "Headphones",
    price: 2999,
    imageUrl: "https://images.unsplash.com/photo-1505740420928-5e560c06d30e",
    description: "Wireless headphones with comfortable ear cushions."
  },
  {
    name: "Sunglasses",
    price: 999,
    imageUrl: "https://images.unsplash.com/photo-1511499767150-a48a237f0083",
    description: "Classic sunglasses with a stylish everyday design."
  },
  {
    name: "Leather Wallet",
    price: 799,
    imageUrl: "https://images.unsplash.com/photo-1627123424574-724758594e93",
    description: "Compact wallet with enough space for cards and cash."
  },
  {
    name: "Casual T-Shirt",
    price: 699,
    imageUrl: "https://images.unsplash.com/photo-1521572163474-6864f9cf17ab",
    description: "Soft and comfortable cotton t-shirt for casual wear."
  },
  {
    name: "Sports Bottle",
    price: 499,
    imageUrl: "https://images.unsplash.com/photo-1602143407151-7111542de6e8",
    description: "Reusable sports bottle for keeping you hydrated."
  }
];

async function seedProducts() {
  try {
    await client.connect();

    const database = client.db("shopping_app");
    const collection = database.collection("products");

    const result = await collection.insertMany(products);

    console.log(`${result.insertedCount} products inserted successfully!`);
  } catch (error) {
    console.error("Failed to insert products:", error);
  } finally {
    await client.close();
  }
}

seedProducts();