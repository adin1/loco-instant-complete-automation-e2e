import React, { useState, useEffect } from 'react';
import { Card, CardContent } from "@/components/ui/card";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { motion } from 'framer-motion';
import { Settings, Home, LogIn, Activity } from 'lucide-react';
import { LineChart, Line, CartesianGrid, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

export default function App() {
  const [data, setData] = useState([
    { name: 'Run 1', success: 80, fail: 20 },
    { name: 'Run 2', success: 90, fail: 10 },
    { name: 'Run 3', success: 70, fail: 30 },
    { name: 'Run 4', success: 95, fail: 5 },
    { name: 'Run 5', success: 88, fail: 12 },
  ]);

  // Simulare actualizare automată
  useEffect(() => {
    const interval = setInterval(() => {
      setData((prev) => {
        const newRun = {
          name: `Run ${prev.length + 1}`,
          success: Math.floor(Math.random() * 30) + 70,
          fail: Math.floor(Math.random() * 20),
        };
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
          <TabsTrigger value="dashboard" className="flex items-center gap-2"><Home size={18}/>Dashboard</TabsTrigger>
          <TabsTrigger value="monitor" className="flex items-center gap-2"><Activity size={18}/>Monitor</TabsTrigger>
          <TabsTrigger value="settings" className="flex items-center gap-2"><Settings size={18}/>Settings</TabsTrigger>
          <TabsTrigger value="login" className="flex items-center gap-2"><LogIn size={18}/>Login</TabsTrigger>
        </TabsList>

        <TabsContent value="dashboard">
          <div className="grid md:grid-cols-2 gap-6">
            <Card className="shadow-lg">
              <CardContent className="p-6">
                <h2 className="text-xl font-semibold mb-2">Automation Overview</h2>
                <p className="text-gray-600 mb-4">View the status of your complete automation pipelines and triggers.</p>
                <Button>View Details</Button>
              </CardContent>
            </Card>

            <Card className="shadow-lg">
              <CardContent className="p-6">
                <h2 className="text-xl font-semibold mb-2">Recent Runs</h2>
                <p className="text-gray-600 mb-4">Monitor recent automation runs with logs and outcomes.</p>
                <Button variant="outline">See Logs</Button>
              </CardContent>
            </Card>
          </div>
        </TabsContent>

        <TabsContent value="monitor">
          <Card className="shadow-lg">
            <CardContent className="p-6">
              <h2 className="text-xl font-semibold mb-4">Real-Time Automation Monitor</h2>
              <p className="text-gray-600 mb-4">Visualize automation task success vs. failure over time. (auto-updating every 4s)</p>
              <ResponsiveContainer width="100%" height={300}>
                <LineChart data={data}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="name" />
                  <YAxis />
                  <Tooltip />
                  <Line type="monotone" dataKey="success" stroke="green" strokeWidth={2} />
                  <Line type="monotone" dataKey="fail" stroke="red" strokeWidth={2} />
                </LineChart>
              </ResponsiveContainer>
              <div className="mt-4 flex justify-end">
                <Button variant="outline" onClick={() => {
                  setData((prev) => [...prev.slice(-4), {
                    name: `Run ${prev.length + 1}`,
                    success: Math.floor(Math.random() * 30) + 70,
                    fail: Math.floor(Math.random() * 20)
                  }]);
                }}>Manual Refresh</Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

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

        <TabsContent value="login">
          <Card className="shadow-md max-w-md mx-auto">
            <CardContent className="p-6">
              <h2 className="text-xl font-semibold mb-4">Login</h2>
              <div className="space-y-3">
                <Input placeholder="Email" type="email" />
                <Input placeholder="Password" type="password" />
                <Button className="w-full">Sign In</Button>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
