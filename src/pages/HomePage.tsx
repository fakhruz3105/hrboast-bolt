import React from 'react';
import Banner from '../components/Banner';
import AboutUs from '../components/AboutUs';
import PricingTable from '../components/PricingTable';
import TrustedBy from '../components/TrustedBy';

export default function HomePage() {
  return (
    <main className="flex-grow">
      <Banner />
      <AboutUs />
      <PricingTable />
      <TrustedBy />
    </main>
  );
}