
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

const ALLOWED_CATEGORIES = [
  "Electronics",
  "Clothing",
  "Accessories",
  "Footwear",
];

const client = new MongoClient(process.env.MONGODB_URI);

// Validate MongoDB document IDs.
function isValidObjectId(id) {
  return (
    ObjectId.isValid(id) &&
    String(new ObjectId(id)) === id
  );
}

// Validate product data for POST and PUT.
function validateProduct(body) {
  const { name, price, imageUrl, description, category } = body;

  if (
    typeof name !== "string" ||
    !name.trim() ||
    typeof imageUrl !== "string" ||
    !imageUrl.trim() ||
    typeof description !== "string" ||
    !description.trim() ||
    typeof category !== "string" ||
    !category.trim() ||
    price === undefined
  ) {
    return "All product fields, including category, are required.";
  }

  if (
    typeof price !== "number" ||
    !Number.isFinite(price) ||
    price <= 0
  ) {
    return "Price must be a positive number.";
  }

  if (!ALLOWED_CATEGORIES.includes(category)) {
    return `Category must be one of: ${ALLOWED_CATEGORIES.join(", ")}.`;
  }

  return null;
}

// Health check.
app.get("/", (req, res) => {
  res.send("Shopping App Backend is running!");
});

// GET all products with optional category and price filters.
app.get("/api/products", async (req, res) => {
  try {
    const { category, minPrice, maxPrice } = req.query;
    const filter = {};

    if (category !== undefined) {
      if (
        typeof category !== "string" ||
        !ALLOWED_CATEGORIES.includes(category)
      ) {
        return res.status(400).json({
          message: "Invalid category.",
          allowedCategories: ALLOWED_CATEGORIES,
        });
      }

      filter.category = category;
    }

    if (minPrice !== undefined || maxPrice !== undefined) {
      if (
        (minPrice !== undefined &&
          (typeof minPrice !== "string" || minPrice.trim() === "")) ||
        (maxPrice !== undefined &&
          (typeof maxPrice !== "string" || maxPrice.trim() === ""))
      ) {
        return res.status(400).json({
          message: "Invalid price range.",
        });
      }

      const min = minPrice === undefined ? 0 : Number(minPrice);
      const max = maxPrice === undefined ? Infinity : Number(maxPrice);

      if (
        !Number.isFinite(min) ||
        min < 0 ||
        (maxPrice !== undefined &&
          (!Number.isFinite(max) || max < 0)) ||
        min > max
      ) {
        return res.status(400).json({
          message: "Invalid price range.",
        });
      }

      filter.price = {};

      if (minPrice !== undefined) {
        filter.price.$gte = min;
      }

      if (maxPrice !== undefined) {
        filter.price.$lte = max;
      }
    }

    const products = client
      .db("shopping_app")
      .collection("products");

    const result = await products.find(filter).toArray();

    res.json(result);
  } catch (error) {
    console.error("Failed to fetch products:", error);

    res.status(500).json({
      message: "Failed to fetch products.",
    });
  }
});

// GET a single product by ID.
app.get("/api/products/:id", async (req, res) => {
  try {
    if (!isValidObjectId(req.params.id)) {
      return res.status(400).json({
        message: "Invalid product ID.",
      });
    }

    const products = client
      .db("shopping_app")
      .collection("products");

    const product = await products.findOne({
      _id: new ObjectId(req.params.id),
    });

    if (!product) {
      return res.status(404).json({
        message: "Product not found.",
      });
    }

    res.json(product);
  } catch (error) {
    console.error("Failed to fetch product:", error);

    res.status(500).json({
      message: "Failed to fetch product.",
    });
  }
});

// CREATE a product.
app.post("/api/products", async (req, res) => {
  try {
    const validationError = validateProduct(req.body);

    if (validationError) {
      return res.status(400).json({
        message: validationError,
      });
    }

    const { name, price, imageUrl, description, category } = req.body;

    const products = client
      .db("shopping_app")
      .collection("products");

    const newProduct = {
      name: name.trim(),
      price,
      imageUrl: imageUrl.trim(),
      description: description.trim(),
      category,
    };

    const result = await products.insertOne(newProduct);

    res.status(201).json({
      message: "Product created successfully.",
      productId: result.insertedId,
    });
  } catch (error) {
    console.error("Failed to create product:", error);

    res.status(500).json({
      message: "Failed to create product.",
    });
  }
});

// UPDATE a product.
app.put("/api/products/:id", async (req, res) => {
  try {
    if (!isValidObjectId(req.params.id)) {
      return res.status(400).json({
        message: "Invalid product ID.",
      });
    }

    const validationError = validateProduct(req.body);

    if (validationError) {
      return res.status(400).json({
        message: validationError,
      });
    }

    const { name, price, imageUrl, description, category } = req.body;

    const products = client
      .db("shopping_app")
      .collection("products");

    const result = await products.updateOne(
      { _id: new ObjectId(req.params.id) },
      {
        $set: {
          name: name.trim(),
          price,
          imageUrl: imageUrl.trim(),
          description: description.trim(),
          category,
        },
      }
    );

    if (result.matchedCount === 0) {
      return res.status(404).json({
        message: "Product not found.",
      });
    }

    res.json({
      message: "Product updated successfully.",
    });
  } catch (error) {
    console.error("Failed to update product:", error);

    res.status(500).json({
      message: "Failed to update product.",
    });
  }
});

// DELETE a product.
app.delete("/api/products/:id", async (req, res) => {
  try {
    if (!isValidObjectId(req.params.id)) {
      return res.status(400).json({
        message: "Invalid product ID.",
      });
    }

    const products = client
      .db("shopping_app")
      .collection("products");

    const result = await products.deleteOne({
      _id: new ObjectId(req.params.id),
    });

    if (result.deletedCount === 0) {
      return res.status(404).json({
        message: "Product not found.",
      });
    }

    res.json({
      message: "Product deleted successfully.",
    });
  } catch (error) {
    console.error("Failed to delete product:", error);

    res.status(500).json({
      message: "Failed to delete product.",
    });
  }
});

// Connect to MongoDB before accepting requests.
async function startServer() {
  try {
    if (!process.env.MONGODB_URI) {
      throw new Error("MONGODB_URI is missing from the .env file.");
    }

    await client.connect();
    console.log("MongoDB connected successfully!");

    app.listen(PORT, () => {
      console.log(`Server running on http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error("Unable to start server:", error);
    await client.close().catch(() => {});
    process.exitCode = 1;
  }
}

startServer();
