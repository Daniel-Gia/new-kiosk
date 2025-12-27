import { networkInterfaces } from 'os';

function getIpAddress() {
  const nets = networkInterfaces();
  const results: { name: string; ip: string }[] = [];

  for (const name of Object.keys(nets)) {
      const interfaces = nets[name];
      if (interfaces) {
          for (const net of interfaces) {
              // !net.internal only filters 127.0.0.1. Docker IPs are still kept here.
              if (net.family === "IPv4" && !net.internal) {
                  results.push({ name, ip: net.address });
              }
          }
      }
  }

  // Sort to prioritize physical interfaces (eth/wlan) over virtual ones (docker/br)
  results.sort((a, b) => {
      const getPriority = (name: string) => {
          // High priority: Physical interfaces
          if (name.startsWith("eth")) return 10;
          if (name.startsWith("wlan")) return 10;
          if (name.startsWith("en")) return 5;
          if (name.startsWith("wl")) return 5;

          // Low priority: Docker and Bridge interfaces
          if (name.startsWith("docker")) return -1;
          if (name.startsWith("br-")) return -1;
          if (name.startsWith("veth")) return -1;

          return 0;
      };
      return getPriority(b.name) - getPriority(a.name);
  });

  return results.length > 0 ? results[0].ip : "No Network Connection";
}

export default function ShowIpPage() {
  const ip = getIpAddress();

  return (
    <div className="min-h-screen w-full bg-black text-white relative cursor-none overflow-hidden">
      <div className="absolute bottom-8 right-8 text-4xl font-mono font-bold opacity-60">
        {ip}
      </div>
    </div>
  );
}
