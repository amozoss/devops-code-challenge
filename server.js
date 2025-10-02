const express = require("express");
const app = express();
const port = process.env.PORT || 8080;

app.get("/", (req, res) => {
  res.send("Hello world");
});

app.get("/health", (req, res) => {
  res.status(200).json({ status: "healthy" });
});

app.listen(port, "0.0.0.0", () => {
  console.log(`Server running on port ${port}`);
});
