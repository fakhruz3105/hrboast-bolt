import React from 'react';
import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { Toaster } from 'react-hot-toast';
import { AuthProvider } from './contexts/AuthContext';
import PublicLayout from './layouts/PublicLayout';
import AdminLayout from './layouts/AdminLayout';

// Public pages
import HomePage from './pages/HomePage';
import LoginPage from './pages/LoginPage';
import RegistrationPage from './pages/RegistrationPage';
import CompanyRegistrationPage from './pages/CompanyRegistrationPage';
import ThankYouPage from './pages/ThankYouPage';
import EmployeeFormPage from './pages/EmployeeFormPage';

// Admin pages
import DashboardPage from './pages/admin/DashboardPage';
import StaffKPIPage from './pages/admin/StaffKPIPage';
import AllStaffPage from './pages/admin/staff/AllStaffPage';
import ProbationStaffPage from './pages/admin/staff/ProbationStaffPage';
import DepartmentsPage from './pages/admin/staff/DepartmentsPage';
import LevelsPage from './pages/admin/staff/LevelsPage';
import CompanyEventsPage from './pages/admin/events/CompanyEventsPage';
import StaffInterviewPage from './pages/admin/interview/StaffInterviewPage';
import ExitInterviewPage from './pages/admin/interview/ExitInterviewPage';
import WarningLetterPage from './pages/admin/misconduct/WarningLetterPage';
import ShowCausePage from './pages/admin/misconduct/ShowCausePage';
import CreateEvaluationPage from './pages/admin/evaluation/CreateEvaluationPage';
import QuarterEvaluationPage from './pages/admin/evaluation/list/QuarterEvaluationPage';
import ManageBenefitsPage from './pages/admin/benefits/ManageBenefitsPage';
import OfficeInventoryPage from './pages/admin/inventory/OfficeInventoryPage';
import AdminEmployeeFormPage from './pages/admin/hr-form/EmployeeFormPage';
import MemoPage from './pages/admin/hr-form/MemoPage';
import UsersPage from './pages/admin/settings/UsersPage';
import MyCompanyPage from './pages/admin/settings/MyCompanyPage';
import RolesPage from './pages/admin/settings/RolesPage';
import CompaniesPage from './pages/admin/settings/CompaniesPage';
import TheDashboardPage from './pages/admin/TheDashboardPage';
import TheMasterPage from './pages/admin/TheMasterPage';

// Staff View pages
import MyDashboardPage from './pages/admin/staff-view/MyDashboardPage';
import MyKPIPage from './pages/admin/staff-view/MyKPIPage';
import MyCompanyEventsPage from './pages/admin/staff-view/MyCompanyEventsPage';
import MyEvaluationsPage from './pages/admin/staff-view/MyEvaluationsPage';
import MyProfilePage from './pages/admin/staff-view/MyProfilePage';
import HRLettersPage from './pages/admin/staff-view/HRLettersPage';
import MyBenefitsPage from './pages/admin/staff-view/MyBenefitsPage';
import MyInventoryPage from './pages/admin/staff-view/MyInventoryPage';
import StaffMemoPage from './pages/admin/staff-view/MemoPage';

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Toaster 
          position="top-right"
          toastOptions={{
            duration: 4000,
            style: {
              background: '#363636',
              color: '#fff',
            },
            success: {
              duration: 3000,
              style: {
                background: '#059669',
              },
            },
            error: {
              duration: 4000,
              style: {
                background: '#DC2626',
              },
            },
          }}
        />
        <Routes>
          {/* Public routes */}
          <Route element={<PublicLayout />}>
            <Route index element={<HomePage />} />
            <Route path="/login" element={<LoginPage />} />
            <Route path="/register" element={<RegistrationPage />} />
            <Route path="/company-register" element={<CompanyRegistrationPage />} />
            <Route path="/thank-you" element={<ThankYouPage />} />
            <Route path="/employee-form/:formId" element={<EmployeeFormPage />} />
          </Route>

          {/* Admin routes */}
          <Route path="/admin" element={<AdminLayout />}>
            {/* Super Admin Routes */}
            <Route path="settings/companies" element={<CompaniesPage />} />
            <Route path="settings/master" element={<TheMasterPage />} />
            <Route path="dashboard/super" element={<TheDashboardPage />} />

            {/* Admin Routes */}
            <Route path="dashboard" element={<DashboardPage />} />
            <Route path="staff-kpi" element={<StaffKPIPage />} />
            <Route path="staff">
              <Route path="all" element={<AllStaffPage />} />
              <Route path="probation" element={<ProbationStaffPage />} />
              <Route path="departments" element={<DepartmentsPage />} />
              <Route path="levels" element={<LevelsPage />} />
            </Route>
            <Route path="events" element={<CompanyEventsPage />} />
            <Route path="evaluation">
              <Route path="create" element={<CreateEvaluationPage />} />
              <Route path="list">
                <Route path="quarter" element={<QuarterEvaluationPage />} />
              </Route>
            </Route>
            <Route path="hr-form">
              <Route path="employee-form" element={<AdminEmployeeFormPage />} />
              <Route path="exit-interview" element={<ExitInterviewPage />} />
              <Route path="memo" element={<MemoPage />} />
            </Route>
            <Route path="misconduct">
              <Route path="warning" element={<WarningLetterPage />} />
              <Route path="show-cause" element={<ShowCausePage />} />
            </Route>
            <Route path="benefits">
              <Route path="manage" element={<ManageBenefitsPage />} />
            </Route>
            <Route path="inventory">
              <Route path="manage" element={<OfficeInventoryPage />} />
            </Route>
            <Route path="settings">
              <Route path="my-company" element={<MyCompanyPage />} />
              <Route path="users" element={<UsersPage />} />
              <Route path="roles" element={<RolesPage />} />
            </Route>

            {/* Staff View Routes */}
            <Route path="staff-view">
              <Route path="dashboard" element={<MyDashboardPage />} />
              <Route path="kpi" element={<MyKPIPage />} />
              <Route path="events" element={<MyCompanyEventsPage />} />
              <Route path="letters" element={<HRLettersPage />} />
              <Route path="evaluations" element={<MyEvaluationsPage />} />
              <Route path="benefits" element={<MyBenefitsPage />} />
              <Route path="inventory" element={<MyInventoryPage />} />
              <Route path="profile" element={<MyProfilePage />} />
              <Route path="memo" element={<StaffMemoPage />} />
            </Route>

            {/* Default redirect */}
            <Route index element={<Navigate to="/admin/dashboard" replace />} />
          </Route>

          {/* Catch all route */}
          <Route path="*" element={<Navigate to="/" replace />} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  );
}