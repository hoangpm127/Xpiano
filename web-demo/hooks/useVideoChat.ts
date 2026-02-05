"use client";

import { useEffect, useRef, useState, useCallback } from "react";

export interface VideoChatProps {
  role: "student" | "teacher";
  sessionId: string;
  onPeerIdReady?: (peerId: string) => void;
}

export default function VideoChat({ role, sessionId, onPeerIdReady }: VideoChatProps) {
  const [myPeerId, setMyPeerId] = useState<string>("");
  const [partnerPeerId, setPartnerPeerId] = useState<string>("");
  const [connectionStatus, setConnectionStatus] = useState<"offline" | "online" | "connecting">("offline");
  const [isMuted, setIsMuted] = useState(false);
  const [isVideoOff, setIsVideoOff] = useState(false);
  const [error, setError] = useState<string>("");

  const localVideoRef = useRef<HTMLVideoElement>(null);
  const remoteVideoRef = useRef<HTMLVideoElement>(null);
  const peerRef = useRef<any>(null);
  const localStreamRef = useRef<MediaStream | null>(null);
  const currentCallRef = useRef<any>(null);

  // Initialize PeerJS
  const initializePeer = useCallback(() => {
    if (typeof window === "undefined" || !window.Peer) {
      setTimeout(initializePeer, 100);
      return;
    }

    try {
      const peer = new window.Peer({
        host: "0.peerjs.com",
        secure: true,
        port: 443,
        path: "/",
        config: {
          iceServers: [
            { urls: "stun:stun.l.google.com:19302" },
            { urls: "stun:stun1.l.google.com:19302" },
          ],
        },
      });

      peer.on("open", (id: string) => {
        console.log("My peer ID:", id);
        setMyPeerId(id);
        setConnectionStatus("online");
        onPeerIdReady?.(id);
        
        // Store in sessionStorage for sharing
        sessionStorage.setItem(`xpiano-${role}-${sessionId}`, id);
      });

      peer.on("call", (call: any) => {
        console.log("Receiving call from:", call.peer);
        setConnectionStatus("connecting");
        
        if (localStreamRef.current) {
          call.answer(localStreamRef.current);
          currentCallRef.current = call;

          call.on("stream", (remoteStream: MediaStream) => {
            console.log("Received remote stream");
            if (remoteVideoRef.current) {
              remoteVideoRef.current.srcObject = remoteStream;
            }
            setPartnerPeerId(call.peer);
            setConnectionStatus("online");
          });

          call.on("close", () => {
            console.log("Call closed");
            handleCallEnd();
          });
        }
      });

      peer.on("error", (err: any) => {
        console.error("Peer error:", err);
        setError(err.type || err.message);
        setConnectionStatus("offline");
      });

      peerRef.current = peer;
    } catch (err: any) {
      console.error("Failed to initialize peer:", err);
      setError(err.message);
    }
  }, [role, sessionId, onPeerIdReady]);

  // Setup local stream
  const setupLocalStream = useCallback(async () => {
    try {
      const stream = await navigator.mediaDevices.getUserMedia({
        video: {
          width: { ideal: 1280 },
          height: { ideal: 720 },
          facingMode: "user",
        },
        audio: {
          echoCancellation: true,
          noiseSuppression: true,
          autoGainControl: true,
        },
      });

      localStreamRef.current = stream;
      if (localVideoRef.current) {
        localVideoRef.current.srcObject = stream;
      }
    } catch (err: any) {
      console.error("Failed to get local stream:", err);
      setError(`Không thể truy cập Camera/Mic: ${err.message}`);
    }
  }, []);

  // Connect to partner
  const connectToPartner = useCallback((partnerId: string) => {
    if (!peerRef.current || !localStreamRef.current) {
      setError("Chưa sẵn sàng để kết nối");
      return;
    }

    setConnectionStatus("connecting");

    try {
      const call = peerRef.current.call(partnerId, localStreamRef.current);
      currentCallRef.current = call;

      call.on("stream", (remoteStream: MediaStream) => {
        console.log("Received remote stream from call");
        if (remoteVideoRef.current) {
          remoteVideoRef.current.srcObject = remoteStream;
        }
        setPartnerPeerId(partnerId);
        setConnectionStatus("online");
      });

      call.on("close", () => {
        handleCallEnd();
      });

      call.on("error", (err: any) => {
        console.error("Call error:", err);
        setError(err.message);
        handleCallEnd();
      });
    } catch (err: any) {
      console.error("Failed to connect:", err);
      setError(err.message);
      setConnectionStatus("online");
    }
  }, []);

  // Handle call end
  const handleCallEnd = useCallback(() => {
    if (remoteVideoRef.current && remoteVideoRef.current.srcObject) {
      const tracks = (remoteVideoRef.current.srcObject as MediaStream).getTracks();
      tracks.forEach((track) => track.stop());
      remoteVideoRef.current.srcObject = null;
    }
    setPartnerPeerId("");
    currentCallRef.current = null;
    if (peerRef.current && !peerRef.current.disconnected) {
      setConnectionStatus("online");
    } else {
      setConnectionStatus("offline");
    }
  }, []);

  // Toggle mute
  const toggleMute = useCallback(() => {
    if (localStreamRef.current) {
      const audioTrack = localStreamRef.current.getAudioTracks()[0];
      if (audioTrack) {
        audioTrack.enabled = !audioTrack.enabled;
        setIsMuted(!audioTrack.enabled);
      }
    }
  }, []);

  // Toggle video
  const toggleVideo = useCallback(() => {
    if (localStreamRef.current) {
      const videoTrack = localStreamRef.current.getVideoTracks()[0];
      if (videoTrack) {
        videoTrack.enabled = !videoTrack.enabled;
        setIsVideoOff(!videoTrack.enabled);
      }
    }
  }, []);

  // Disconnect
  const disconnect = useCallback(() => {
    if (currentCallRef.current) {
      currentCallRef.current.close();
    }
    handleCallEnd();
  }, [handleCallEnd]);

  // Initialize on mount
  useEffect(() => {
    setupLocalStream();
    initializePeer();

    return () => {
      if (currentCallRef.current) {
        currentCallRef.current.close();
      }
      if (localStreamRef.current) {
        localStreamRef.current.getTracks().forEach((track) => track.stop());
      }
      if (peerRef.current) {
        peerRef.current.destroy();
      }
    };
  }, [setupLocalStream, initializePeer]);

  // Auto-connect when partner ID is available
  useEffect(() => {
    if (!myPeerId || partnerPeerId) return;

    const checkInterval = setInterval(() => {
      const partnerRole = role === "student" ? "teacher" : "student";
      const storedPartnerId = sessionStorage.getItem(`xpiano-${partnerRole}-${sessionId}`);
      
      if (storedPartnerId && storedPartnerId !== myPeerId) {
        console.log(`Found partner ID: ${storedPartnerId}`);
        clearInterval(checkInterval);
        connectToPartner(storedPartnerId);
      }
    }, 2000);

    return () => clearInterval(checkInterval);
  }, [myPeerId, partnerPeerId, role, sessionId, connectToPartner]);

  return {
    myPeerId,
    partnerPeerId,
    connectionStatus,
    isMuted,
    isVideoOff,
    error,
    localVideoRef,
    remoteVideoRef,
    toggleMute,
    toggleVideo,
    disconnect,
    connectToPartner,
  };
}
