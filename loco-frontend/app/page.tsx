"use client";

import React, { useState, useEffect } from "react";
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import {
  Tabs,
  TabsList,
  TabsTrigger,
  TabsContent,
} from "@/components/ui/tabs";
import { motion } from "framer-motion";
import { Settings, Home, LogIn, Activity } from "lucide-react";
import {
  LineChart,
  Line,
  CartesianGrid,
  XAxis,
  YAxis,
  Tooltip,
  ResponsiveContainer,
} from "recharts";
import { toast } from "sonner";

export default function App() {
  const [data, setData] = useState([
    { name: "Run 1", success: 80, fail: 20 },
    { name: "Run 2", success: 90, fail: 10 },
    { name: "Run 3", success: 70, fail: 30 },
    { name: "Run 4", success: 95, fail: 5 },
    { name: "Run 5", success: 88, fail: 12 },
  ]);

  // Actualizare automată + toast
  useEffect(() => {
    const interval = setInterval(() => {
      setData((prev) => {
        const newRun = {
          name: `Run ${prev.length + 1}`,
          success: Math.floor(Math.random() * 30) + 70,
          fail: Math.floor(Math.random() * 20),
        };
        toast.success(`New automation run: ${newRun.success}% success`);
        const updated = [...prev.slice(-4), newRun];
        return updated;
      });
    }, 4000);
    return () => clearInterval(interval);
  }, []);

  return (
    <div className="min-h-screen bg-gradient-to-br from-gray-50 to-gray-200 p-6">
      <motion.h1
        className="text-3xl font-bold mb-6 text-center text-gray-800"
        initial={{ opacity: 0, y: -10 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.6 }}
      >
        Loco Instant Automation Dashboard
      </motion.h1>

      <Tabs defaultValue="dashboard" className="max-w-6xl mx-auto">
        <TabsList className="flex justify-center mb-4">
          <TabsTrigger value="dashboard" className="flex items-center gap-2">
            <Home size={18} /> Dashboard
          </TabsTrigger>
          <TabsTrigger value="monitor" className="flex items-center gap-2">
            <Activity size={18} /> Monitor
          </TabsTrigger>
          <TabsTrigger value="settings" className="flex items-center gap-2">
            <Settings size={18} /> Settings
          </TabsTrigger>
          <TabsTrigger value="login" className="flex items-center gap-2">
            <LogIn size={18} /> Login
          </TabsTrigger>
        </TabsList>

        {/* DASHBOARD */}
        <TabsContent value="dashboard">
          <div className="grid md:grid-cols-2 gap-6">
            <Card className="shadow-lg">
              <CardContent className="p-6">
                <h2 className="text-xl font-semibold mb-2">
                  Automation Overview
                </h2>
                <p className="text-gray-600 mb-4">
                  View the status of your complete automation pipelines and
                  triggers.
                </p>
                <Button>View Details</Button>
              </CardContent>
            </Card>

            <Card className="shadow-lg">
              <CardContent className="p-6">
                <h2 className="text-xl font-semibold mb-2">Recent Runs</h2>
                <p className="text-gray-600 mb-4">
                  Monitor recent automation runs with logs and outcomes.
                </p>
                <Button variant="outline">See Logs</Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        {/* MONITOR */}
        <TabsContent value="monitor">
          <Card className="shadow-lg">
            <CardContent className="p-6">
              <h2 className="text-xl font-semibold mb-4">
                Real-Time Automation Monitor
              </h2>
              <p className="text-gray-600 mb-4">
                Visualize automation task success vs. failure over time.
                (auto-updating every 4s)
              </p>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Line
                    type="monotone"
                    dataKey="success"
                    stroke="green"
                    strokeWidth={2}
                  />
                  <Line
                    type="monotone"
                    dataKey="fail"
                    stroke="red"
                    strokeWidth={2}
                  />
                </LineChart>
              </ResponsiveContainer>
              <div className="mt-4 flex justify-end">
                <Button
                  variant="outline"
                  onClick={() => {
                    setData((prev) => {
                      const newRun = {
                        name: `Run ${prev.length + 1}`,
                        success: Math.floor(Math.random() * 30) + 70,
                        fail: Math.floor(Math.random() * 20),
                      };
                      toast.info(`Manual refresh: ${newRun.success}% success`);
                      return [...prev.slice(-4), newRun];
                    });
                  }}
                >
                  Manual Refresh
                </Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* SETTINGS */}
        <TabsContent value="settings">
          <Card className="shadow-md max-w-lg mx-auto">
            <CardContent className="p-6">
              <h2 className="text-xl font-semibold mb-4">Settings</h2>
              <div className="space-y-3">
                <Input placeholder="Webhook URL" />
                <Input placeholder="API Key" type="password" />
                <Button>Save Settings</Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

{/* LOGIN */}
<TabsContent value="login">
  <Card className="shadow-md max-w-md mx-auto">
    <CardContent className="p-6">
      <h2 className="text-xl font-semibold mb-4">Login</h2>
      <form
        className="space-y-3"
        onSubmit={async (e) => {
          e.preventDefault();
          const form = e.currentTarget;
          const email = (form.elements.namedItem("email") as HTMLInputElement).value;
          const password = (form.elements.namedItem("password") as HTMLInputElement).value;

          try {
            const res = await fetch("http://localhost:3000/auth/login", {
              method: "POST",
              headers: { "Content-Type": "application/json" },
              body: JSON.stringify({ email, password }),
            });

            if (!res.ok) throw new Error("Invalid credentials");
            const data = await res.json();

            localStorage.setItem("token", data.access_token);
            alert(`✅ Welcome, ${data.user.name || data.user.email}!`);
          } catch (err) {
            alert("❌ Login failed. Check email or password.");
          }
        }}
      >
        <Input name="email" placeholder="Email" type="email" required />
        <Input name="password" placeholder="Password" type="password" required />
        <Button className="w-full" type="submit">
          Sign In
        </Button>
      </form>
    </CardContent>
  </Card>
</TabsContent>


      </Tabs>
    </div>
  );
}
