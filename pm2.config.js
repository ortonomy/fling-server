module.exports = {
  apps: [
    {
      name: "main",
      script: "lib/app.js",
      watch: true,
      interpreter: "babel-node",
      env: {
        "NODE_ENV": "DEVELOPMENT"
      },
      "node_args": ["--inspect"]
    },
    {
      name: "worker",
      script: "lib/worker.js",
      watch: true,
      interpreter: "babel-node",
      env: {
        "PGHOST": "localhost",
        "PGDATABASE": "fling",
        "PGUSER": "flingapp_admin",
        "PGPASSWORD": process.env.ADMINPASS,
        "PGPORT": 5432,
        "NODE_ENV": "DEVELOPMENT"
      }
    }
  ]
}