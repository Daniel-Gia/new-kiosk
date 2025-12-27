import { networkInterfaces } from 'os';

function getIpAddress() {
  const nets = networkInterfaces();
  const results: string[] = [];

  for (const name of Object.keys(nets)) {
    const interfaces = nets[name];
    if (interfaces) {
      for (const net of interfaces) {
        // Skip over non-IPv4 and internal (i.e. 127.0.0.1) addresses
        if (net.family === 'IPv4' && !net.internal) {
          results.push(net.address);
        }
      }
    }
  }
  
  // Return the first found IP, or a fallback message
  return results.length > 0 ? results[0] : 'No Network Connection';
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
