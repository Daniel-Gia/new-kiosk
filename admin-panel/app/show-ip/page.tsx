import { networkInterfaces } from 'os';
export const dynamic = "force-dynamic";
function getIpAddresses() {
    const nets = networkInterfaces();
    const results: { name: string; ip: string }[] = [];

    for (const name of Object.keys(nets)) {
        const interfaces = nets[name];
        if (interfaces) {
            for (const net of interfaces) {
                if (net.family === "IPv4" && !net.internal) {
                    results.push({ name, ip: net.address });
                }
            }
        }
    }

    // Sort to prioritize physical interfaces (eth/wlan) over virtual ones (docker/br)
    // results.sort((a, b) => {
    //     const getPriority = (name: string) => {
    //         // High priority: Physical interfaces
    //         if (name.startsWith("eth")) return 10;
    //         if (name.startsWith("wlan")) return 10;
    //         if (name.startsWith("en")) return 5;
    //         if (name.startsWith("wl")) return 5;

    //         // Low priority: Docker and Bridge interfaces
    //         if (name.startsWith("docker")) return -1;
    //         if (name.startsWith("br-")) return -1;
    //         if (name.startsWith("veth")) return -1;

    //         return 0;
    //     };
    //     return getPriority(b.name) - getPriority(a.name);
    // });

    return results;
}

export default function ShowIpPage() {
    const ips = getIpAddresses();

    return (
        <div className="min-h-screen w-full bg-black text-white relative cursor-none overflow-hidden flex items-end justify-end p-8">
            <div className="flex flex-col items-end gap-2 opacity-60">
                {ips.length > 0 ? (
                    ips.map((item) => (
                        <div key={item.ip} className="text-4xl font-mono font-bold">
                            <span className="text-xl mr-4 text-gray-400">{item.name}</span>
                            {item.ip}
                        </div>
                    ))
                ) : (
                    <div className="text-4xl font-mono font-bold">No Network Connection</div>
                )}
            </div>
        </div>
    );
}
