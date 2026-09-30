
const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { MongoClient } = require("mongodb");

const app = express();
app.use(cors());
const PORT = 5000;

const client = new MongoClient(process.env.MONGODB_URI);

async function connectDB() {
  try {
    await client.connect();
    console.log("MongoDB connected successfully!");
  } catch (error) {
    console.error("MongoDB connection failed:", error);
  }
}

app.get("/", (req, res) => {
  res.send("Shopping App Backend is running!");
});

app.get("/api/products", async (req, res) => {
  try {
    const database = client.db("shopping_app");
    const products = database.collection("products");

    const result = await products.find().toArray();

    res.json(result);
  } catch (error) {
    console.error("Failed to fetch products:", error);
    res.status(500).json({
      message: "Failed to fetch products"
    });
  }
});


app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

connectDB();