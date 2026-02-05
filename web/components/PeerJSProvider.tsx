import Script from "next/script";

export default function PeerJSProvider({ children }: { children: React.ReactNode }) {
  return (
    <>
      <Script 
        src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js"
        strategy="beforeInteractive"
      />
      {children}
    </>
  );
}
