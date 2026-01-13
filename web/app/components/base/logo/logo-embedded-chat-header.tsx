import type { FC } from 'react'
import { cn } from '@/utils/classnames'
import { basePath } from '@/utils/var'

type LogoEmbeddedChatHeaderProps = {
  className?: string
}

const LogoEmbeddedChatHeader: FC<LogoEmbeddedChatHeaderProps> = ({
  className,
}) => {
  // TODO: Add logo-embedded-chat-header.png and @2x/@3x variants for better quality
  return (
    <img
      src={`${basePath}/logo/logo.png`}
      alt="Dooza logo"
      className={cn('block h-6 w-auto', className)}
    />
  )
}

export default LogoEmbeddedChatHeader
