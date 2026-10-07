#!/usr/bin/env node
/**
 * Builds Next.js, starts production server, renders each App Store slide to PNG
 * via Puppeteer + window.__SUNRISE_EXPORT_SLIDE__.
 *
 * Usage: node scripts/export-png.mjs
 * Output: exported-store-screenshots/*.png
 */

import { spawn } from "node:child_process";
import { mkdirSync, writeFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import http from "node:http";

const __dirname = dirname(fileURLToPath(import.meta.url));
const root = join(__dirname, "..");
const outDir = join(root, "exported-store-screenshots");
const SLIDE_COUNT = 6;

function waitForPort(port, maxMs = 120000) {
  const start = Date.now();
  return new Promise((resolve, reject) => {
    const tryOnce = () => {
      const req = http.get(`http://127.0.0.1:${port}`, (res) => {
        res.resume();
        resolve();
      });
      req.on("error", () => {
        if (Date.now() - start > maxMs) {
          reject(new Error(`Port ${port} did not open within ${maxMs}ms`));
          return;
        }
        setTimeout(tryOnce, 400);
      });
    };
    tryOnce();
  });
}

async function main() {
  mkdirSync(outDir, { recursive: true });

  console.log("Building Next.js…");
  await new Promise((resolve, reject) => {
    const b = spawn("npm", ["run", "build"], {
      cwd: root,
      stdio: "inherit",
      shell: true,
    });
    b.on("close", (code) =>
      code === 0 ? resolve() : reject(new Error(`build exited ${code}`)),
    );
  });

  console.log("Starting production server on :3000…");
  const server = spawn("npm", ["run", "start", "--", "-p", "3000"], {
    cwd: root,
    stdio: "inherit",
    shell: true,
    env: { ...process.env, PORT: "3000" },
  });

  await waitForPort(3000);

  const puppeteer = (await import("puppeteer")).default;
  const browser = await puppeteer.launch({
    headless: true,
    args: ["--no-sandbox", "--disable-setuid-sandbox", "--font-render-hinting=none"],
  });
  const page = await browser.newPage();
  await page.setViewport({ width: 1280, height: 900, deviceScaleFactor: 1 });

  console.log("Loading app…");
  await page.goto("http://127.0.0.1:3000", {
    waitUntil: "networkidle0",
    timeout: 120000,
  });

  await page.waitForFunction(
    () => typeof window.__SUNRISE_EXPORT_SLIDE__ === "function",
    { timeout: 90000 },
  );
  await page.waitForFunction(
    () => !document.body?.textContent?.includes("Loading assets"),
    { timeout: 90000 },
  );

  for (let i = 0; i < SLIDE_COUNT; i++) {
    console.log(`Exporting slide ${i + 1}/${SLIDE_COUNT}…`);
    const result = await page.evaluate(async (idx) => {
      const fn = window.__SUNRISE_EXPORT_SLIDE__;
      if (!fn) throw new Error("export hook missing");
      return fn(idx);
    }, i);

    if (!result?.filename || !result?.dataUrl) {
      throw new Error(`Slide ${i} returned empty`);
    }
    const b64 = result.dataUrl.replace(/^data:image\/\w+;base64,/, "");
    writeFileSync(join(outDir, result.filename), Buffer.from(b64, "base64"));
    console.log("  →", result.filename);
  }

  await browser.close();
  server.kill("SIGTERM");
  console.log("Done. PNGs in:", outDir);
}

main().catch((e) => {
  console.error(e);
  process.exit(1);
});
