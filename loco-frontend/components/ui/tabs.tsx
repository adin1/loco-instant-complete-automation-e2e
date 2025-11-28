"use client";
import * as React from "react";

export function Tabs({
  defaultValue,
  children,
  className = "",
}: {
  defaultValue?: string;
  children: React.ReactNode;
  className?: string;
}) {
  const [activeTab, setActiveTab] = React.useState(defaultValue);
  const tabs = React.Children.toArray(children);

  const tabList = tabs.filter(
    (tab: any) => tab.type.displayName === "TabsList"
  );
  const tabContent = tabs.filter(
    (tab: any) => tab.type.displayName === "TabsContent"
  );

  return (
    <div className={className}>
      {React.cloneElement(tabList[0] as any, { activeTab, setActiveTab })}
      {tabContent.map((content: any, index) =>
        React.cloneElement(content, { key: index, activeTab })
      )}
    </div>
  );
}

export function TabsList({
  children,
  activeTab,
  setActiveTab,
  className = "",
}: any) {
  return (
    <div className={`flex gap-2 justify-center border-b pb-2 ${className}`}>
      {React.Children.map(children, (child: any) =>
        React.cloneElement(child, { activeTab, setActiveTab })
      )}
    </div>
  );
}
TabsList.displayName = "TabsList";

export function TabsTrigger({
  children,
  value,
  activeTab,
  setActiveTab,
  className = "",
}: any) {
  const isActive = activeTab === value;
  return (
    <button
      onClick={() => setActiveTab(value)}
      className={`px-4 py-2 rounded-md font-medium transition-all ${
        isActive
          ? "bg-blue-600 text-white"
          : "text-gray-700 hover:bg-gray-100"
      } ${className}`}
    >
      {children}
    </button>
  );
}
TabsTrigger.displayName = "TabsTrigger";

export function TabsContent({
  children,
  value,
  activeTab,
  className = "",
}: any) {
  if (activeTab !== value) return null;
  return <div className={`mt-4 ${className}`}>{children}</div>;
}
TabsContent.displayName = "TabsContent";
