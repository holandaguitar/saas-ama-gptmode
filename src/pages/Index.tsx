import React from 'react';
import { AMALayout } from "@/components/layout/AMALayout";
import { Dashboard } from "@/components/dashboard/Dashboard";

const Index = () => {
  return (
    <AMALayout title="Dashboard">
      <Dashboard />
    </AMALayout>
  );
};

export default Index;
