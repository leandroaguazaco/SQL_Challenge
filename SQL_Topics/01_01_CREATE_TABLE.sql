CREATE TABLE "regions" (
  "region_id" INTEGER PRIMARY KEY NOT NULL,
  "region_name" VARCHAR(19)
);

CREATE TABLE "customer_nodes" (
  "customer_id" INTEGER PRIMARY KEY NOT NULL,
  "region_id" INTEGER NOT NULL,
  "node_id" INTEGER NOT NULL,
  "start_date" DATE,
  "end_date" DATE
);

CREATE TABLE "customer_transactions" (
  "customer_id" INTEGER NOT NULL,
  "txn_date" DATE,
  "txn_type" VARCHAR(10),
  "txn_amount" INTEGER
);

ALTER TABLE "customer_nodes" ADD FOREIGN KEY ("region_id") REFERENCES "regions" ("region_id");

ALTER TABLE "customer_transactions" ADD FOREIGN KEY ("customer_id") REFERENCES "customer_nodes" ("customer_id");
