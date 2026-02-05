import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Navbar from "@/components/Navbar";
import Script from "next/script";
import { SocketProvider } from "@/contexts/SocketContext";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Xpiano - Nền tảng học đàn & cho thuê Piano đầu tiên tại Việt Nam",
  description: "Thuê đàn piano ship tận nhà, học online với giáo viên real-time MIDI feedback",
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="vi">
      <head>
        <Script 
          src="https://unpkg.com/peerjs@1.5.2/dist/peerjs.min.js"
          strategy="beforeInteractive"
        />
      </head>
      <body className={inter.className}>
        <SocketProvider>
          <Navbar />
          {children}
        </SocketProvider>
      </body>
    </html>
  );
}
