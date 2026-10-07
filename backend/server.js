
const dns = require("dns");
dns.setServers(["8.8.8.8", "8.8.4.4"]);

require("dotenv").config();
const express = require("express");
const cors = require("cors");
const { MongoClient, ObjectId } = require("mongodb");

const app = express();
app.use(cors());
app.use(express.json());
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

app.get("/api/products/:id", async (req, res) => {
  try {
    const database = client.db("shopping_app");
    const products = database.collection("products");

    const product = await products.findOne({
      _id: new ObjectId(req.params.id),
    });

    if (!product) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.json(product);
  } catch (error) {
    console.error("Failed to fetch product:", error);

    res.status(500).json({
      message: "Failed to fetch product",
    });
  }
});

app.post("/api/products", async (req, res) => {
  try {
    const { name, price, imageUrl, description } = req.body;

    if (!name || price === undefined || !imageUrl || !description) {
      return res.status(400).json({
        message: "All product fields are required",
      });
    }

    if (typeof price !== "number" || price <= 0) {
      return res.status(400).json({
        message: "Price must be a positive number",
      });
    }

    const database = client.db("shopping_app");
    const products = database.collection("products");

    const newProduct = {
      name,
      price,
      imageUrl,
      description,
    };

    const result = await products.insertOne(newProduct);

    res.status(201).json({
      message: "Product created successfully",
      productId: result.insertedId,
    });
  } catch (error) {
    console.error("Failed to create product:", error);

    res.status(500).json({
      message: "Failed to create product",
    });
  }
});

app.put("/api/products/:id", async (req, res) => {
  try {
    const { name, price, imageUrl, description } = req.body;

    if (!name || price === undefined || !imageUrl || !description) {
      return res.status(400).json({
        message: "All product fields are required",
      });
    }

    if (typeof price !== "number" || price <= 0) {
      return res.status(400).json({
        message: "Price must be a positive number",
      });
    }

    const database = client.db("shopping_app");
    const products = database.collection("products");

    const result = await products.updateOne(
      { _id: new ObjectId(req.params.id) },
      {
        $set: {
          name,
          price,
          imageUrl,
          description,
        },
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.json({
      message: "Product updated successfully",
    });
  } catch (error) {
    console.error("Failed to update product:", error);

    res.status(500).json({
      message: "Failed to update product",
    });
  }
});

app.delete("/api/products/:id", async (req, res) => {
  try {
    const database = client.db("shopping_app");
    const products = database.collection("products");

    const result = await products.deleteOne({
      _id: new ObjectId(req.params.id),
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({
        message: "Product not found",
      });
    }

    res.json({
      message: "Product deleted successfully",
    });
  } catch (error) {
    console.error("Failed to delete product:", error);

    res.status(500).json({
      message: "Failed to delete product",
    });
  }
});

app.listen(PORT, () => {
  console.log(`Server running on http://localhost:${PORT}`);
});

connectDB();