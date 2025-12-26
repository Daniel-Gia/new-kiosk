import { NextResponse } from "next/server";
import { readFile, writeFile } from "node:fs/promises";
import path from "node:path";

export const runtime = "nodejs";

const DEFAULT_URL_FILE =
  process.env.DEFAULT_URL_FILE ??
  path.join(process.cwd(), "..", "settings", "default_url.txt");

const CHROME_REMOTE_URL =
  process.env.CHROME_REMOTE_URL ?? "http://127.0.0.1:9222";

function normalizeHttpUrl(input: string): string {
  const trimmed = input.trim();
  const parsed = new URL(trimmed);
  if (parsed.protocol !== "http:" && parsed.protocol !== "https:") {
    throw new Error("Only http(s) URLs are allowed.");
  }
  return parsed.toString();
}

export async function GET() {
  try {
    const current = (await readFile(DEFAULT_URL_FILE, "utf8"))
      .split(/\r?\n/)[0]
      ?.trim();

    return NextResponse.json({ url: current ?? "" }, { status: 200 });
  } catch {
    return NextResponse.json({ url: "" }, { status: 200 });
  }
}

export async function POST(req: Request) {
  let urlRaw: string | undefined;

  try {
    const body = (await req.json()) as { url?: string };
    urlRaw = body.url;
  } catch {
    return NextResponse.json({ error: "Invalid JSON body." }, { status: 400 });
  }

  if (!urlRaw) {
    return NextResponse.json({ error: "Missing 'url'." }, { status: 400 });
  }

  let url: string;
  try {
    url = normalizeHttpUrl(urlRaw);
  } catch (e) {
    return NextResponse.json(
      { error: e instanceof Error ? e.message : "Invalid URL." },
      { status: 400 },
    );
  }

  // Persist for reboot
  await writeFile(DEFAULT_URL_FILE, `${url}\n`, "utf8");

  // Open now via DevTools
  const endpoint = `${CHROME_REMOTE_URL}/json/new?${encodeURIComponent(url)}`;
  try {
    const response = await fetch(endpoint, { method: "PUT" });
    if (!response.ok) {
      return NextResponse.json(
        {
          error: `DevTools returned HTTP ${response.status}. URL was saved, but browser did not update.`,
        },
        { status: 502 },
      );
    }
  } catch {
    return NextResponse.json(
      {
        error: "Failed to reach DevTools. URL was saved, but browser did not update.",
      },
      { status: 502 },
    );
  }

  return NextResponse.json({ ok: true, url }, { status: 200 });
}
