import React from 'react';
import { SidebarProvider } from "@/components/ui/sidebar";
import { AMASidebar } from './AMASidebar';
import { AMAHeader } from './AMAHeader';

interface AMALayoutProps {
  children: React.ReactNode;
  title: string;
}

export const AMALayout: React.FC<AMALayoutProps> = ({ children, title }) => {
  return (
    <SidebarProvider>
      <div className="min-h-screen flex w-full bg-background">
        <AMASidebar />
        <div className="flex-1 flex flex-col">
          <AMAHeader title={title} />
          <main className="flex-1 p-6">
            {children}
          </main>
        </div>
      </div>
    </SidebarProvider>
  );
};