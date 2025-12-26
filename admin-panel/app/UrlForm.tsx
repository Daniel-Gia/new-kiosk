"use client";

import { useEffect, useState } from "react";

type GetUrlResponse = { url?: string };

type PostUrlResponse =
  | { ok: true; url: string }
  | { error: string };

export default function UrlForm() {
  const [url, setUrl] = useState<string>("");
  const [status, setStatus] = useState<string>("");

  useEffect(() => {
    (async () => {
      try {
        const response = await fetch("/api/url", { cache: "no-store" });
        const data = (await response.json()) as GetUrlResponse;
        if (typeof data.url === "string") {
          setUrl(data.url);
        }
      } catch {
        // ignore
      }
    })();
  }, []);

  async function onSubmit(e: React.FormEvent) {
    e.preventDefault();
    setStatus("Updating...");

    try {
      const response = await fetch("/api/url", {
        method: "POST",
        headers: { "content-type": "application/json" },
        body: JSON.stringify({ url }),
      });

      const data = (await response.json()) as PostUrlResponse;
      if (!response.ok) {
        setStatus("error" in data ? data.error : "Update failed.");
        return;
      }

      setStatus("Updated.");
    } catch {
      setStatus("Request failed.");
    }
  }

  return (
    <form onSubmit={onSubmit} className="flex w-full flex-col gap-3">
      <label className="text-sm font-medium">Kiosk URL</label>
      <input
        className="w-full rounded-md border border-zinc-300 bg-white px-3 py-2 text-black outline-none focus:border-zinc-500"
        value={url}
        onChange={(e) => setUrl(e.target.value)}
        placeholder="https://example.com"
        inputMode="url"
        autoComplete="off"
      />
      <button
        className="rounded-md bg-black px-4 py-2 text-white hover:bg-zinc-800"
        type="submit"
      >
        Save + Open on kiosk
      </button>
      <div className="min-h-5 text-sm text-zinc-600">{status}</div>
    </form>
  );
}
