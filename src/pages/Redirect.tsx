import React from 'react';
import { Redirect } from 'react-router-dom';

const RedirectPage: React.FC = () => {
  return <Redirect to="/messageList" />;
};
export default RedirectPage;
