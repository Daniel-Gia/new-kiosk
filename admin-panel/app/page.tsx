import UrlForm from "./UrlForm";

export default function Home() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-50 px-6 font-sans dark:bg-black">
      <main className="w-full max-w-xl rounded-lg border border-zinc-200 bg-white p-6 dark:border-white/10 dark:bg-black">
        <h1 className="mb-1 text-xl font-semibold text-black dark:text-zinc-50">
          Kiosk Admin
        </h1>
        <p className="mb-6 text-sm text-zinc-600 dark:text-zinc-400">
          Set the URL to open now (via DevTools) and on reboot (via
          settings/default_url.txt).
        </p>
        <UrlForm />
      </main>
    </div>
  );
}
