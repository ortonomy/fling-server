module.exports = {
  apps: [
    {
      name: "main",
      script: "lib/app.js",
      watch: true,
      interpreter: "babel-node",
      env: {
        "NODE_ENV": "DEVELOPMENT"
      }
    },
    {
      name: "worker",
      script: "lib/worker.js",
      watch: true,
      interpreter: "babel-node",
      env: {
        "PGHOST": "localhost",
        "PGDATABASE": "fling",
        "PGUSER": "gregoryorton",
        "PGPASSWORD": null,
        "PGPORT": 5432,
        "NODE_ENV": "DEVELOPMENT"
      }
    }
  ]
}